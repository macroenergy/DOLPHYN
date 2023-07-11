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
	write_power(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)

Function for reporting the different values of power generated by the different technologies in operation.
"""
function write_power(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)
	dfGen = inputs["dfGen"]
	G = inputs["G"]     # Number of resources (generators, storage, DR, and DERs)
	T = inputs["T"]     # Number of time steps (hours)

	# Power injected by each resource in each time step
	dfPower = DataFrame(Resource = inputs["RESOURCES"], Zone = dfGen[!,:Zone], AnnualSum = Array{Union{Missing,Float32}}(undef, G))
	if setup["ParameterScale"] ==1
		for i in 1:G
			dfPower[!,:AnnualSum][i] = sum(inputs["omega"].* (value.(EP[:vP])[i,:])) * ModelScalingFactor
		end
		dfPower = hcat(dfPower, DataFrame((value.(EP[:vP]))* ModelScalingFactor, :auto))
	else
		for i in 1:G
			dfPower[!,:AnnualSum][i] = sum(inputs["omega"].* (value.(EP[:vP])[i,:]))
		end
		dfPower = hcat(dfPower, DataFrame(value.(EP[:vP]), :auto))
	end

	auxNew_Names=[Symbol("Resource");Symbol("Zone");Symbol("AnnualSum");[Symbol("t$t") for t in 1:T]]
	rename!(dfPower,auxNew_Names)



	total = DataFrame(["Total" 0 sum(dfPower[!,:AnnualSum]) fill(0.0, (1,T))], :auto)
	for t in 1:T
		if v"1.3" <= VERSION < v"1.4"
			total[!,t+3] .= sum(dfPower[!,Symbol("t$t")][1:G])
		elseif v"1.4" <= VERSION < v"1.9"
			total[:,t+3] .= sum(dfPower[:,Symbol("t$t")][1:G])
		end
	end
	rename!(total,auxNew_Names)

	if setup["ModelH2"] == 1 && setup["ModelH2G2P"] == 1
		dfH2G2P = inputs["dfH2G2P"]
		H = inputs["H2_G2P_ALL"]     # Number of resources (generators, storage, DR, and DERs)
		T = inputs["T"]     # Number of time steps (hours)
	
		# Power injected by each resource in each time step
		# dfH2G2POut_annual = DataFrame(Resource = inputs["H2_RESOURCES_NAME"], Zone = dfH2G2P[!,:Zone], AnnualSum = Array{Union{Missing,Float32}}(undef, H))
		dfPG2POut = DataFrame(Resource = inputs["H2_G2P_NAME"], Zone = dfH2G2P[!,:Zone], AnnualSum = Array{Union{Missing,Float32}}(undef, H))
	
		for i in 1:H
			dfPG2POut[!,:AnnualSum][i] = sum(inputs["omega"].* (value.(EP[:vPG2P])[i,:]))
		end
		# Load hourly values
		dfPG2POut = hcat(dfPG2POut, DataFrame((value.(EP[:vPG2P])), :auto))
	
		# Add labels
		auxNew_Names=[Symbol("Resource");Symbol("Zone");Symbol("AnnualSum");[Symbol("t$t") for t in 1:T]]
		rename!(dfPG2POut,auxNew_Names)
	
		total_w_H2G2P = DataFrame(["Total" 0 sum(dfPower[!,:AnnualSum])+sum(dfPG2POut[!,:AnnualSum]) fill(0.0, (1,T))], :auto)
	
		for t in  1:T
			total_w_H2G2P[:,t+3] .= sum(dfPower[!,Symbol("t$t")][1:G]) + sum(dfPG2POut[:,Symbol("t$t")][1:H])
		end

		rename!(total_w_H2G2P,auxNew_Names)

		dfPower_w_H2G2P = vcat(dfPower, dfPG2POut, total_w_H2G2P)	
		CSV.write(string(path,sep,"power_w_H2G2P.csv"), dftranspose(dfPower_w_H2G2P, false), writeheader=false)
	end


	dfPower = vcat(dfPower, total)
 	CSV.write(string(path,sep,"power.csv"), dftranspose(dfPower, false), writeheader=false)

	return dfPower
end
