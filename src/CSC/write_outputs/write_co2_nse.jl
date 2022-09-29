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
	write_nse(path::AbstractString, setup::Dict, inputs::Dict, EP::Model)

Function for reporting non-served energy for every model zone, time step and cost-segment.
"""
function write_co2_nse(path::AbstractString, setup::Dict, inputs::Dict, EP::Model)

	T = inputs["T"]     # Number of time steps (hours)
	Z = inputs["Z"]     # Number of zones
    CO2_SEG = inputs["CO2_SEG"] # Number of load curtailment segments
	# Non-served energy/demand curtailment by segment in each time step
	dfNse = DataFrame()
	dfTemp = Dict()
	for z in 1:Z
		dfTemp = DataFrame(Segment=zeros(CO2_SEG), Zone=zeros(CO2_SEG), AnnualSum = Array{Union{Missing,Float32}}(undef, CO2_SEG))
		dfTemp[!,:Segment] = (1:CO2_SEG)
		dfTemp[!,:Zone] = fill(z,(CO2_SEG))

			for i in 1:CO2_SEG
				dfTemp[!,:AnnualSum][i] = sum(inputs["omega"].* (value.(EP[:vCO2NSE])[i,:,z]))
			end
			dfTemp = hcat(dfTemp, DataFrame(value.(EP[:vCO2NSE])[:,:,z], :auto))

		if z == 1
			dfNse = dfTemp
		else
			dfNse = vcat(dfNse,dfTemp)
		end
	end

	auxNew_Names=[Symbol("Segment");Symbol("Zone");Symbol("AnnualSum");[Symbol("t$t") for t in 1:T]]
	rename!(dfNse,auxNew_Names)
	total = DataFrame(["Total" 0 sum(dfNse[!,:AnnualSum]) fill(0.0, (1,T))], :auto)
	for t in 1:T
		if v"1.3" <= VERSION < v"1.4"
			total[!,t+3] .= sum(dfNse[!,Symbol("t$t")][1:Z])
		elseif v"1.4" <= VERSION < v"1.8"
			total[:,t+3] .= sum(dfNse[:,Symbol("t$t")][1:Z])
		end
	end
	rename!(total,auxNew_Names)
	dfNse = vcat(dfNse, total)

	CSV.write(joinpath(path, "CSC_nse.csv"),  dftranspose(dfNse, false), writeheader=false)
end