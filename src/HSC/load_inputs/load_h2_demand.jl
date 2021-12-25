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

function load_h2_demand(setup::Dict, path::AbstractString, sep::AbstractString, inputs_load::Dict)
    
    H2_load_in = DataFrame(CSV.File(string(path,sep,"H2_load_data.csv"), header=true), copycols=true)

    # Number of demand curtailment/lost load segments
	inputs_load["H2_SEG"]=size(collect(skipmissing(H2_load_in[!,:Demand_Segment])),1)

    # Demand in tonnes per hour for each zone
	#println(names(load_in))
	start = findall(s -> s == "Load_H2_tonne_per_hr_z1", names(H2_load_in))[1] #gets the starting column number of all the columns, with header "Load_H2_z1"
	
	# Max value of non-served energy in $/(tonne)
	inputs_load["H2_Voll"] = collect(skipmissing(H2_load_in[!,:Voll]))
	# Demand in Tonnes per hour
	inputs_load["H2_D"] =Matrix(H2_load_in[1:inputs_load["T"],start:start-1+inputs_load["Z"]]) #form a matrix with columns as the different zonal load H2 demand values and rows as the hours
	

    # Cost of non-served energy/demand curtailment (for each segment)
	H2_SEG = inputs_load["H2_SEG"]  # Number of demand segments
	inputs_load["pC_H2_D_Curtail"] = zeros(H2_SEG)
	inputs_load["pMax_H2_D_Curtail"] = zeros(H2_SEG)
	for s in 1:H2_SEG
		# Cost of each segment reported as a fraction of value of non-served energy - scaled implicitly
		inputs_load["pC_H2_D_Curtail"][s] = collect(skipmissing(H2_load_in[!,:Cost_of_Demand_Curtailment_per_Tonne]))[s]*inputs_load["Voll"][1]
		# Maximum hourly demand curtailable as % of the max demand (for each segment)
		inputs_load["pMax_H2_D_Curtail"][s] = collect(skipmissing(H2_load_in[!,:Max_Demand_Curtailment]))[s]
	end
    
	println("H2_load_data.csv Successfully Read!")

    return inputs_load

end
