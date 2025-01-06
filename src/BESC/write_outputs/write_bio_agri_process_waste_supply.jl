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
write_bio_agri_process_waste_supply(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)

Function for reporting the AgriProcessWaste biomass purchased from different resources across zones with time.
"""
function write_bio_agri_process_waste_supply(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)
	dfAgri_Process_Waste = inputs["dfAgri_Process_Waste"]
	H = inputs["AGRI_PROCESS_WASTE_SUPPLY_RES_ALL"]     # Number of resources (generators, storage, DR, and DERs)
	T = inputs["T"]     # Number of time steps (hours)

	# Hydrogen injected by each resource in each time step
	# dfAgri_Process_WasteOut_annual = DataFrame(Resource = inputs["AGRI_PROCESS_WASTE_SUPPLY_NAME"], Zone = dfAgri_Process_Waste[!,:Zone], AnnualSum = Array{Union{Missing,Float32}}(undef, H))
	dfAgri_Process_WasteOut = DataFrame(Resource = inputs["AGRI_PROCESS_WASTE_SUPPLY_NAME"], Zone = dfAgri_Process_Waste[!,:Zone], AnnualSum = Array{Union{Missing,Float32}}(undef, H))

	AgriProcessWastesupply = value.(EP[:vAgri_Process_Waste_biomass_purchased])
    dfAgri_Process_WasteOut.AnnualSum .= AgriProcessWastesupply * inputs["omega"]

	# Load hourly values
	dfAgri_Process_WasteOut = hcat(dfAgri_Process_WasteOut, DataFrame((value.(EP[:vAgri_Process_Waste_biomass_purchased])), :auto))

	# Add labels
	auxNew_Names=[Symbol("Resource");Symbol("Zone");Symbol("AnnualSum");[Symbol("t$t") for t in 1:T]]
	rename!(dfAgri_Process_WasteOut,auxNew_Names)

	total = DataFrame(["Total" 0 sum(dfAgri_Process_WasteOut[!,:AnnualSum]) fill(0.0, (1,T))], :auto)

 	total[:,4:T+3] .= sum(AgriProcessWastesupply, dims=1)

	rename!(total,auxNew_Names)

	dfAgri_Process_WasteOut = vcat(dfAgri_Process_WasteOut, total)
 	CSV.write(string(path,sep,"BESC_Agri_Process_Waste_supply.csv"), dftranspose(dfAgri_Process_WasteOut, false), writeheader=false)
	
	return dfAgri_Process_WasteOut


end