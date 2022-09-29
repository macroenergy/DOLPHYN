"""
DOLPHYN: Decision Optimization for Low-carbon Power and Hydrogen Networks
Copyright (C) 2021, Massachusetts Institute of Technology and Peking University
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.
A complete copy of the GNU General Public License v2 (GPLv2) is available
in LICENSE.txt. Users uncompressing this from an archive may not have
received this license file. If not, see <http://www.gnu.org/licenses/>.
"""

@doc raw"""
	load_co2_capture_variability(path::AbstractString, setup::Dict, inputs::Dict)

Function for reading input parameters related to hourly maximum capacity factors for all generators (plus storage and flexible demand resources)
"""
function load_co2_capture_variability(path::AbstractString, setup::Dict, inputs::Dict)

	# Set indices for internal use
	T = inputs["T"]   # Number of time steps (hours)
	Zones = inputs["Zones"] # List of modeled zones

	# Hourly capacity factors
	if setup["TimeDomainReduction"] == 1
		capture_var = DataFrame(CSV.File(joinpath(path, "CSC_capture_variability.csv"), header=true), copycols=true)
	else # Run without Time Domain Reduction OR Getting original input data for Time Domain Reduction
		capture_var = DataFrame(CSV.File(joinpath(path, "CSC_capture_variability.csv"), header=true), copycols=true)
	end

	# Reorder DataFrame to R_ID order (order provided in Generators_data.csv)
	select!(capture_var, [:Time_Index; Symbol.(inputs["CO2_RESOURCES_NAME"])])

	# Maximum capture output and variability of each carbon capture resource
	inputs["pCO2_Max"] = transpose(Matrix{Float64}(capture_var[1:T, 2:end]))

	println("CSC_capture_variability.csv Successfully Read!")

	return inputs
end