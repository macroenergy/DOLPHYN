"""
DOLPHYN: Decision Optimization for Low-carbon Power and Hydrogen Networks
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
    h2_generation(EP::Model, inputs::Dict, UCommit::Int, Reserves::Int)

The h2_production module creates decision variables, expressions, and constraints related to various hydrogen generation technologies (electrolyzers, natural gas reforming etc.)

This module uses the following 'helper' functions in separate files: ```h2_generation_commit()``` for resources subject to unit commitment decisions and constraints (if any) and ```h2_generation_no_commit()``` for resources not subject to unit commitment (if any).
"""
function syn_fuels_production(EP::Model, inputs::Dict, setup::Dict)

	if !isempty(inputs["SYN_FUELS_RES_ALL"])
	# expressions, variables and constraints common to all types of syn fuels
		EP = syn_fuels_production_all(EP::Model, inputs::Dict, setup::Dict)
	end

    SYN_FUEL_RES_COMMIT = inputs["SYN_FUEL_RES_COMMIT"]
	SYN_FUEL_RES_NO_COMMIT = inputs["SYN_FUEL_RES_NO_COMMIT"]

	if !isempty(SYN_FUEL_RES_COMMIT)
        error("Synthesis Fuel Commit Not Yet Implemented")
		EP = syn_fuel_res_commit(EP::Model, inputs::Dict, setup::Dict)
	end

	if !isempty(SYN_FUEL_RES_NO_COMMIT)
		EP = syn_fuel_res_no_commit(EP::Model, inputs::Dict,setup::Dict)
	end

	return EP
end
