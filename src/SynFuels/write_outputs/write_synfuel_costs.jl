"""
DOLPHYN: Decision Optimization for Low-carbon for Power and Hydrogen Networks
Copyright (C) 2021,  Massachusetts Institute of Technology
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
	write_costs(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)

Function for writing the costs pertaining to the objective function (fixed, variable O&M etc.).
"""
function write_synfuel_costs(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)
	## Cost results
	dfSynFuels= inputs["dfSynFuels"]

	Z = inputs["Z"]     # Number of zones
	T = inputs["T"]     # Number of time steps (hours)

	if !isempty(inputs["SYN_FUEL_RES_COMMIT"])
		ErrorException("Writing outputs for commit units not implemented")
	end

	dfSynFuelsCost = DataFrame(Costs = ["cSFTotal", "cSFFix", "cSFVar", "cSFByProdRev"])
	if setup["ParameterScale"]==1 # Convert costs in millions to $
		cSFVar = value(EP[:eTotalCSFProdVarOut])* (ModelScalingFactor^2)
		cSFFix = value(EP[:eFixed_Cost_Syn_Fuel_total])*ModelScalingFactor^2
		cSFByProdRev = - value(EP[:eTotalCSFByProdRevenueOut])*ModelScalingFactor^2
	else
		cSFVar = value(EP[:eTotalCSFProdVarOut])
		cSFFix = value(EP[:eFixed_Cost_Syn_Fuel_total])
		cSFByProdRev = - value(EP[:eTotalCSFByProdRevenueOut])
	end

	if setup["CO2Cap"]==4 
        ErrorException("Carbon Price for SynFuels Not implemented")
    end

	# Adding emissions penalty to variable cost depending on type of emissions policy constraint
	# Emissions penalty is already scaled by adjusting the value of carbon price used in emissions_HSC.jl
	#if((setup["CO2Cap"]==4 && setup["SystemCO2Constraint"]==2)||(setup["H2CO2Cap"]==4 && setup["SystemCO2Constraint"]==1))
	#	cSFVar  = cSFVar + value(EP[:eCH2GenTotalEmissionsPenalty])
	#end
	 
    cSFTotal = cSFVar + cSFFix + cSFByProdRev

    dfSynFuelsCost[!,Symbol("Total")] = [cSFTotal, cSFFix, cSFVar, cSFByProdRev]

	for z in 1:Z
		tempCTotal = 0
		tempCFix = 0
		tempCVar = 0
		tempCByProd = 0
		for y in dfSynFuels[dfSynFuels[!,:Zone].==z,:][!,:R_ID]
			tempCFix = tempCFix +
				value.(EP[:eFixed_Cost_Syn_Fuels_per_type])[y]

			tempCVar = tempCVar +
				sum(value.(EP[:eCSFProdVar_out])[y,:])

			tempCByProd = tempCByProd + -sum(value.(EP[:eTotalCSFByProdRevenueOutTK])[:,y])

			tempCTotal = tempCTotal +
					value.(EP[:eFixed_Cost_Syn_Fuels_per_type])[y] +
					sum(value.(EP[:eCSFProdVar_out])[y,:]) +
					-sum(value.(EP[:eTotalCSFByProdRevenueOutTK])[:,y])

			
		end

		if setup["ParameterScale"] == 1 # Convert costs in millions to $
			tempCFix = tempCFix * (ModelScalingFactor^2)
			tempCVar = tempCVar * (ModelScalingFactor^2)
			tempCByProd = tempCByProd * (ModelScalingFactor^2)
			tempCTotal = tempCTotal * (ModelScalingFactor^2)
		end

		if setup["CO2Cap"]==4 
			ErrorException("Carbon Price for SynFuels Not implemented")
		end

		# Add emisions penalty related costs if the constraints are active
		# Emissions penalty is already scaled previously depending on value of ParameterScale and hence not scaled here
		#if((setup["CO2Cap"]==4 && setup["SystemCO2Constraint"]==2)||(setup["H2CO2Cap"]==4 && setup["SystemCO2Constraint"]==1))
		#	tempCVar  = tempCVar + value.(EP[:eCH2EmissionsPenaltybyZone])[z]
		#	tempCTotal = tempCTotal +value.(EP[:eCH2EmissionsPenaltybyZone])[z]
		#end

		dfSynFuelsCost[!,Symbol("Zone$z")] = [tempCTotal, tempCFix, tempCVar, tempCByProd]
	end
	CSV.write(string(path,sep,"SynFuel_costs.csv"), dfSynFuelsCost)
end
