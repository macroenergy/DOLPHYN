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
	load_co2_capture(setup::Dict, path::AbstractString, sep::AbstractString, inputs_capture::Dict)


"""
function load_co2_capture(setup::Dict, path::AbstractString, sep::AbstractString, inputs_capture::Dict)

	# Read in direct air capture related inputs
    co2_capture = DataFrame(CSV.File(string(path,sep,"CSC_capture.csv"), header=true), copycols=true)

    # Add Resource IDs after reading to prevent user errors
	co2_capture[!,:R_ID] = 1:size(collect(skipmissing(co2_capture[!,1])),1)

    # Store DataFrame of capture units/resources input data for use in model
	inputs_capture["dfCO2Capture"] = co2_capture

	# Name of CO2 capture resources
	inputs_capture["CO2_RESOURCES_NAME"] = collect(skipmissing(co2_capture[!,:CO2_Resource]))
	
	# Set of CO2 resources eligible for unit committment - either continuous or discrete capacity -set by setup["CO2captureCommit"]
	inputs_capture["CO2_CAPTURE_COMMIT"] = co2_capture[co2_capture.CO2_CAPTURE_TYPE.==1 ,:R_ID]
	# Set of CO2 resources eligible for unit committment
	inputs_capture["CO2_CAPTURE_NO_COMMIT"] = co2_capture[co2_capture.CO2_CAPTURE_TYPE.==2 ,:R_ID]

    # Set of all CO2 capture Units - can be either commit or new commit
    inputs_capture["CO2_CAPTURE"] = union(inputs_capture["CO2_CAPTURE_COMMIT"], inputs_capture["CO2_CAPTURE_NO_COMMIT"])

    # Set of all resources eligible for new capacity - includes both storage and capture
	# DEV NOTE: Should we allow investment in flexible demand capacity later on?
	inputs_capture["CO2_CAPTURE_NEW_CAP"] = intersect(co2_capture[co2_capture.New_Build.==1 ,:R_ID], co2_capture[co2_capture.Max_Cap_tonne_p_hr.!=0,:R_ID]) 

	# Fixed cost per start-up ($ per MW per start) if unit commitment is modelled
	start_cost = convert(Array{Float64}, collect(skipmissing(inputs_capture["dfCO2Capture"][!,:Start_Cost_per_tonne_p_hr])))
	
	inputs_capture["C_CO2_Start"] = inputs_capture["dfCO2Capture"][!,:Cap_Size_tonne_p_hr].* start_cost

	println("CSC_capture.csv Successfully Read!")

    return inputs_capture

end

