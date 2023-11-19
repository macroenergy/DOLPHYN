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
	green_h2_share_requirement(EP::Model, inputs::Dict, setup::Dict)

This function establishes constraints that can be flexibily applied to define alternative forms of policies that require generation of a quantity of tonne-h2 from green h2 in the entire system across the entire year

	"""
function green_h2_share_requirement(EP::Model, inputs::Dict, setup::Dict)

	print_and_log("Green H2 Share Requirement Policies Module")

	T = inputs["T"]     # Number of time steps (hours)
	Z = inputs["Z"]     # Number of zones

	H2_ELECTROLYZER = inputs["H2_ELECTROLYZER"]
	GreenH2Share = setup["GreenH2Share"]

	## Green H2 Share Requirements (minimum H2 share from electrolyzer) constraint
	@expression(EP, eGlobalGreenH2Balance[t=1:T], sum(EP[:vH2Gen][y,t] for y in H2_ELECTROLYZER) )
	@expression(EP, eGlobalGreenH2Demand[t=1:T], sum(inputs["H2_D"][t,z] for z = 1:Z) )

	@expression(EP, eAnnualGlobalGreenH2Balance, sum(inputs["omega"][t] * EP[:eGlobalGreenH2Balance][t] for t = 1:T) )
	@expression(EP, eAnnualGlobalGreenH2Demand, sum(inputs["omega"][t] * EP[:eGlobalGreenH2Demand][t] for t = 1:T) )

	#Only if modeling a net-zero system with negative emission technologies (NETs) avaialble, then we can set a equality constraint
	#Otherwise solution can be infeasible if we force the model to uptake less than 100% of green H2 in a net-zero system without NETs
	#NETs = DAC in CO2 supply chain, and BECCS in bioenergy supply chain

	if setup["ModelCO2"] == 0 #If NETs are not available then green H2 have to be above share to avoid infeasibility
		@constraint(EP, cGreenH2ShareRequirement, eAnnualGlobalGreenH2Balance >= GreenH2Share * eAnnualGlobalGreenH2Demand)
	elseif setup["ModelCO2"] == 1 #If NETs are available, we are able to force a specific proportion of green H2 without running into infeasibility
		@constraint(EP, cGreenH2ShareRequirement, eAnnualGlobalGreenH2Balance == GreenH2Share * eAnnualGlobalGreenH2Demand)
	end



	return EP
end