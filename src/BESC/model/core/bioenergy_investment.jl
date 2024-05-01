"""
DOLPHYN: Decision Optimization for Low-carbon Power and Hydrogen Networks
Copyright (C) 2022,  Massachusetts Institute of Technology
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
A complete copy of the GNU General Public License v2 (GPLv2) is available
in LICENSE.txt.  Users uncompressing this from an archive may not have
received this license file.  If not, see <http://www.gnu.org/licenses/>.
"""

@doc raw"""
	bioenergy_investment(EP::Model, inputs::Dict, setup::Dict)

Sets up constraints common to all biorefinery resources.

This function defines the expressions and constraints keeping track of total available biorefinery capacity $y_{r}^{\textrm{B,Bio}}$ based on its input biomass in tonne per hour as well as constraints on capacity.

The expression defined in this file named after ```vCapacity_BIO_per_type``` covers all variables $y_{r}^{\textrm{B,Bio}}$.

The total capacity of each biorefinery resource is defined as the sum of newly invested capacity based on the assumption there are no existing biorefinery resources. 

**Cost expressions**

This module additionally defines contributions to the objective function from investment costs of biorefinery (fixed O\&M plus investment costs) from all resources $r \in \mathcal{R}$:

```math
\begin{equation*}
	\textrm{C}^{\textrm{Bio,c}} = \sum_{r \in \mathcal{R}} \sum_{z \in \mathcal{Z}} y_{r, z}^{\textrm{B,Bio}}\times \textrm{c}_{r}^{\textrm{Bio,INV}} + \sum_{r \in \mathcal{R}} \sum_{z \in \mathcal{Z}} y_{r, z}^{\textrm{B,Bio}} \times \textrm{c}_{r}^{\textrm{Bio,FOM}}
\end{equation*}
```

**Constraints on biorefinery resource capacity**

For resources where upper bound $\overline{y_{r}^{\textrm{B,Bio}}}$ and lower bound $\underline{y_{r}^{\textrm{B,Bio}}}$ of capacity is defined, then we impose constraints on minimum and maximum biorefinery resource input biomass capacity.

```math
\begin{equation*}
	\underline{y_{r}^{\textrm{B,Bio}}} \leq y_{r}^{\textrm{B,Bio}} \leq \overline{y_{r}^{\textrm{B,Bio}}} \quad \forall r \in \mathcal{R}
\end{equation*}
```
"""
function bioenergy_investment(EP::Model, inputs::Dict, setup::Dict)
	
	println("Biorefinery Fixed Cost module")

	dfbioenergy = inputs["dfbioenergy"]
	BIO_RES_ALL = inputs["BIO_RES_ALL"]
	BIO_H2 = inputs["BIO_H2"]

	Z = inputs["Z"]
	T = inputs["T"]
	
	#General variables for non-piecewise and piecewise cost functions
	@variable(EP,vCapacity_BIO_per_type[i in 1:BIO_RES_ALL])
	@variable(EP,vCAPEX_BIO_per_type[i in 1:BIO_RES_ALL])

	if setup["ParameterScale"] == 1
		BIO_Capacity_Min_Limit = dfbioenergy[!,:Min_capacity_tonne_per_hr]/ModelScalingFactor
		BIO_Capacity_Max_Limit = dfbioenergy[!,:Max_capacity_tonne_per_hr]/ModelScalingFactor
	else
		BIO_Capacity_Min_Limit = dfbioenergy[!,:Min_capacity_tonne_per_hr]
		BIO_Capacity_Max_Limit = dfbioenergy[!,:Max_capacity_tonne_per_hr]
	end
		
	if setup["ParameterScale"] == 1
		BIO_Inv_Cost_per_tonne_per_hr_yr = dfbioenergy[!,:Inv_Cost_per_tonne_per_hr_yr]/ModelScalingFactor # $M/kton
		BIO_Fixed_OM_Cost_per_tonne_per_hr_yr = dfbioenergy[!,:Fixed_OM_Cost_per_tonne_per_hr_yr]/ModelScalingFactor # $M/kton
	else
		BIO_Inv_Cost_per_tonne_per_hr_yr = dfbioenergy[!,:Inv_Cost_per_tonne_per_hr_yr]
		BIO_Fixed_OM_Cost_per_tonne_per_hr_yr = dfbioenergy[!,:Fixed_OM_Cost_per_tonne_per_hr_yr]
	end

	#Min and max capacity constraints
	@constraint(EP,cMinCapacity_per_unit_BIO[i in 1:BIO_RES_ALL], EP[:vCapacity_BIO_per_type][i] >= BIO_Capacity_Min_Limit[i])
	@constraint(EP,cMaxCapacity_per_unit_BIO[i in 1:BIO_RES_ALL], EP[:vCapacity_BIO_per_type][i] <= BIO_Capacity_Max_Limit[i])

	#Investment cost = CAPEX
	@expression(EP, eCAPEX_BIO_per_type[i in 1:BIO_RES_ALL], EP[:vCapacity_BIO_per_type][i] * BIO_Inv_Cost_per_tonne_per_hr_yr[i])

	#Fixed OM cost
	@expression(EP, eFixed_OM_BIO_per_type[i in 1:BIO_RES_ALL], EP[:vCapacity_BIO_per_type][i] * BIO_Fixed_OM_Cost_per_tonne_per_hr_yr[i])

	#Total fixed cost = CAPEX + Fixed OM
	@expression(EP, eFixed_Cost_BIO_per_type[i in 1:BIO_RES_ALL], EP[:eFixed_OM_BIO_per_type][i] + EP[:eCAPEX_BIO_per_type][i])

	#Total cost
	#Expression for total CAPEX for all resoruce types (For output)
	@expression(EP,eCAPEX_BIO_total, sum(EP[:eCAPEX_BIO_per_type][i] for i in 1:BIO_RES_ALL))

	#Expression for total Fixed OM for all resoruce types (For output)
	@expression(EP,eFixed_OM_BIO_total, sum(EP[:eFixed_OM_BIO_per_type][i] for i in 1:BIO_RES_ALL))

	#Expression for total Fixed Cost for all resoruce types (For output and to add to objective function)
	@expression(EP,eFixed_Cost_BIO_total, sum(EP[:eFixed_Cost_BIO_per_type][i] for i in 1:BIO_RES_ALL))

	EP[:eObj] += EP[:eFixed_Cost_BIO_total]

	#####################################################################################################################################
	#For Bio-H2 to use in LCOH calculations
	#Investment cost of Bio H2
	#if setup["Bio_H2_On"] == 1
	#	@expression(EP, eCAPEX_BIO_H2_per_type[i in BIO_H2], EP[:vCapacity_BIO_per_type][i] * BIO_Inv_Cost_per_tonne_per_hr_yr[i])

		#Fixed OM cost of Bio H2
	#	@expression(EP, eFixed_OM_BIO_H2_per_type[i in BIO_H2], EP[:vCapacity_BIO_per_type][i] * BIO_Fixed_OM_Cost_per_tonne_per_hr_yr[i])

		#Total fixed cost of Bio H2
	#	@expression(EP, eFixed_Cost_BIO_H2_per_type[i in BIO_H2], EP[:eFixed_OM_BIO_H2_per_type][i] + EP[:eCAPEX_BIO_H2_per_type][i])

		#Expression for total Fixed Cost for Bio H2 (For output in LCOH)
	#	@expression(EP,eFixed_Cost_BIO_H2_total, sum(EP[:eFixed_Cost_BIO_H2_per_type][i] for i in BIO_H2))
	#end

    return EP

end