"""
CaptureX: An Configurable Capacity Expansion Model
Copyright (C) 2021,  Massachusetts Institute of Technology
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Captureeral Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Captureeral Public License for more details.
A complete copy of the GNU Captureeral Public License v2 (GPLv2) is available
in LICENSE.txt.  Users uncompressing this from an archive may not have
received this license file.  If not, see <http://www.gnu.org/licenses/>.
"""

@doc raw"""
	write_co2_capture(EP::Model, path::AbstractString, inputs::Dict, setup::Dict)

Function for writing the different values of CO2 captured by the different technologies in operation.
"""
function write_co2_capture(EP::Model, path::AbstractString, inputs::Dict, setup::Dict)
	
	dfCO2Capture = inputs["dfCO2Capture"]
	
	K = inputs["CO2_RES_ALL"]     # Number of resources (Capture units, storage, DR, and DERs)
	T = inputs["T"]     # Number of time steps (hours)

	# Carbon captured by each resource in each time step
	dfCO2CaptureOut = DataFrame(Resource = inputs["CO2_RESOURCES_NAME"], Zone = dfCO2Capture[!,:Zone], AnnualSum = Array{Union{Missing,Float32}}(undef, K))

	for k in 1:K
		dfCO2CaptureOut[!,:AnnualSum][k] = sum(inputs["omega"].* (value.(EP[:vCO2Capture])[k,:]))
	end

	# Load hourly values
	dfCO2CaptureOut = hcat(dfCO2CaptureOut, DataFrame((value.(EP[:vCO2Capture])), :auto))

	# Add labels
	auxNew_Names=[Symbol("Resource");Symbol("Zone");Symbol("AnnualSum");[Symbol("t$t") for t in 1:T]]
	rename!(dfCO2CaptureOut,auxNew_Names)

	total = DataFrame(["Total" 0 sum(dfCO2CaptureOut[!,:AnnualSum]) fill(0.0, (1,T))], :auto)

	for t in 1:T
		total[:,t+3] .= sum(dfCO2CaptureOut[:,Symbol("t$t")][1:K])
	end

	rename!(total,auxNew_Names)
	dfCO2CaptureOut = vcat(dfCO2CaptureOut, total)

 	CSV.write(joinpath(path, "DAC_co2_capture.csv"), dftranspose(dfCO2CaptureOut, false), writeheader=false)
	
	return dfCO2CaptureOut

end
