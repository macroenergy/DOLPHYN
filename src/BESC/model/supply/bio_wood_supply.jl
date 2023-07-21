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
    bio_wood_supply(EP::Model, inputs::Dict, UCommit::Int, Reserves::Int)

This module defines the amount of bio wood supplies used into the network by zone $z$ by at time period $t, along with the cost and CO2 emissions associated with it.
"""

function bio_wood_supply(EP::Model, inputs::Dict, setup::Dict)

	println("Bioenergy woody biomass supply cost module")

	#Define sets
	T = inputs["T"]     # Number of time steps (hours)
    Z = inputs["Z"]     # Zones

	#Variables
	@variable(EP,vWood_biomass_utilized_per_zone_per_time[z in 1:Z, t in 1:T] >= 0)
	@variable(EP,vWood_biomass_supply_cost_per_zone_per_time[z in 1:Z, t in 1:T] >= 0)

	Wood_biomass_supply_df = inputs["Wood_biomass_supply_df"]

	if setup["ParameterScale"] ==1
		Wood_biomass_Supply_Max = Wood_biomass_supply_df[!,:Max_tonne_per_hr]/ModelScalingFactor #Convert to ktonne
		Wood_biomass_cost_per_tonne = Wood_biomass_supply_df[!,:Cost_per_tonne_per_hr]/ModelScalingFactor #Convert to $M/ktonne
		Wood_biomass_emission_per_tonne = Wood_biomass_supply_df[!,:Emissions_tonne_per_tonne] #Convert to ktonne/ktonne = tonne/tonne
	else
		Wood_biomass_Supply_Max = Wood_biomass_supply_df[!,:Max_tonne_per_hr]
		Wood_biomass_cost_per_tonne = Wood_biomass_supply_df[!,:Cost_per_tonne_per_hr]
		Wood_biomass_emission_per_tonne = Wood_biomass_supply_df[!,:Emissions_tonne_per_tonne]
	end

	#Add to Obj, need to account for time weight omega
	@expression(EP, eWood_biomass_supply_cost_per_zone_per_time[z in 1:Z, t in 1:T], inputs["omega"][t] * EP[:vWood_biomass_utilized_per_zone_per_time][z,t] * Wood_biomass_cost_per_tonne[z])
	@expression(EP, eWood_biomass_emission_per_zone_per_time[z in 1:Z, t in 1:T], EP[:vWood_biomass_utilized_per_zone_per_time][z,t] * Wood_biomass_emission_per_tonne[z])

	#Output without time weight to show hourly cost
	@expression(EP, eWood_biomass_supply_cost_per_zone_per_time_output[z in 1:Z, t in 1:T], EP[:vWood_biomass_utilized_per_zone_per_time][z,t] * Wood_biomass_cost_per_tonne[z])

	#Total biomass supply cost per zone
	@expression(EP, eWood_biomass_supply_cost_per_zone[z in 1:Z], sum(EP[:eWood_biomass_supply_cost_per_zone_per_time][z,t] for t in 1:T))

	#Total biomass supply cost
	@expression(EP, eWood_biomass_supply_cost, sum(EP[:eWood_biomass_supply_cost_per_zone][z] for z in 1:Z))

	#Max biomass supply constraint
	@constraint(EP,cWood_biomass_Max[z in 1:Z, t in 1:T], EP[:vWood_biomass_utilized_per_zone_per_time][z,t] <= Wood_biomass_Supply_Max[z])

	EP[:eObj] += EP[:eWood_biomass_supply_cost]

	return EP

end