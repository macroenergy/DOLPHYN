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
	write_co2_storage_balance_zone(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)

Function for reporting total CO2 storage balance across different zones.
"""
function write_co2_storage_balance_zone(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)
	Z = inputs["Z"]     # Number of zones

	dfCost = DataFrame(Costs = ["Power CCS", "H2 CCS", "DAC Capture", "DAC Fuel CCS", "Biorefinery Capture", "Synfuel Plant Capture", "Synfuel Plant Consumption", "Syn NG Plant Capture", "Syn NG Plant Consumption", "CO2 Pipeline Import", "CO2 Storage", "Total"])

	Power_CCS = sum(sum(inputs["omega"].* (value.(EP[:ePower_CO2_captured_per_zone_per_time])[z,:])) for z in 1:Z)

	H2_CCS = 0

	if setup["ModelH2"] == 1
		H2_CCS = sum(sum(inputs["omega"].* (value.(EP[:eHydrogen_CO2_captured_per_zone_per_time])[z,:])) for z in 1:Z)
	end

	DAC_Capture =  sum(sum(inputs["omega"].* (value.(EP[:eDAC_CO2_Captured_per_zone_per_time])[z,:])) for z in 1:Z)
	DAC_Fuel_CCS = sum(sum(inputs["omega"].* (value.(EP[:eDAC_Fuel_CO2_captured_per_zone_per_time])[z,:])) for z in 1:Z)

	Biorefinery_Capture = 0

	if setup["ModelBESC"] == 1
		Biorefinery_Capture = sum(sum(inputs["omega"].* (value.(EP[:eBiorefinery_CO2_captured_per_zone_per_time])[z,:])) for z in 1:Z)
	end

	Synfuel_Production_Capture = 0
	Synfuel_Production_Consumption = 0

	if setup["ModelLFSC"] == 1 && setup["ModelSyntheticFuels"] == 1
		Synfuel_Production_Capture = sum(sum(inputs["omega"].* (value.(EP[:eSyn_Fuels_CO2_Capture_Per_Zone_Per_Time])[z,:])) for z in 1:Z)
		Synfuel_Production_Consumption = - sum(sum(inputs["omega"].* (value.(EP[:eSyn_Fuel_CO2_Cons_Per_Zone_Per_Time])[z,:])) for z in 1:Z)
	end

	Syn_NG_Production_Capture = 0
	Syn_NG_Production_Consumption = 0

	if setup["ModelNGSC"] == 1 && setup["ModelSyntheticNG"] == 1
		Syn_NG_Production_Capture = sum(sum(inputs["omega"].* (value.(EP[:eSyn_NG_CO2_Capture_Per_Zone_Per_Time])[z,:])) for z in 1:Z)
		Syn_NG_Production_Consumption = - sum(sum(inputs["omega"].* (value.(EP[:eSyn_NG_CO2_Cons_Per_Zone_Per_Time])[z,:])) for z in 1:Z)
	end

	CO2_Pipeline_Import = 0

	if setup["ModelCO2Pipelines"] == 1
		CO2_Pipeline_Import = sum(sum(inputs["omega"].* (value.(EP[:ePipeZoneCO2Demand])[:,z])) for z in 1:Z)
	end

	CO2_Storage = 0

	if setup["ModelCO2Storage"] == 1
		CO2_Storage = - sum(sum(inputs["omega"].* (value.(EP[:eCO2_Injected_per_zone])[z,:])) for z in 1:Z)
	end

	# Define total CO2 storage balance
	cTotal = Power_CCS + H2_CCS + DAC_Capture + DAC_Fuel_CCS + Biorefinery_Capture + Synfuel_Production_Capture + Synfuel_Production_Consumption + Syn_NG_Production_Capture + Syn_NG_Production_Consumption + CO2_Pipeline_Import + CO2_Storage

	# Define total column, i.e. column 2
	dfCost[!,Symbol("Total")] = [Power_CCS, H2_CCS, DAC_Capture, DAC_Fuel_CCS, Biorefinery_Capture, Synfuel_Production_Capture, Synfuel_Production_Consumption, Syn_NG_Production_Capture, Syn_NG_Production_Consumption, CO2_Pipeline_Import, CO2_Storage, cTotal]

	################################################################################################################################
	# Computing zonal cost breakdown by cost category
	for z in 1:Z
		tempPower_CCS = 0
		tempH2_CCS = 0
		tempDAC_Capture = 0
		tempDAC_Fuel_CCS = 0
		tempBiorefinery_Capture = 0
		tempSynfuel_Production_Capture = 0
		tempSynfuel_Production_Consumption = 0
		tempSyn_NG_Production_Capture = 0
		tempSyn_NG_Production_Consumption = 0
		tempCO2_Pipeline_Import = 0
		tempCO2_Storage = 0

		tempPower_CCS = tempPower_CCS + sum(inputs["omega"].* (value.(EP[:ePower_CO2_captured_per_zone_per_time])[z,:]))

		if setup["ModelH2"] == 1
			tempH2_CCS = tempH2_CCS + sum(inputs["omega"].* (value.(EP[:eHydrogen_CO2_captured_per_zone_per_time])[z,:]))
		end

		tempDAC_Capture = tempDAC_Capture + sum(inputs["omega"].* (value.(EP[:eDAC_CO2_Captured_per_zone_per_time])[z,:]))
		tempDAC_Fuel_CCS = tempDAC_Fuel_CCS + sum(inputs["omega"].* (value.(EP[:eDAC_Fuel_CO2_captured_per_zone_per_time])[z,:]))

		if setup["ModelBESC"] == 1
			tempBiorefinery_Capture = tempBiorefinery_Capture + sum(inputs["omega"].* (value.(EP[:eBiorefinery_CO2_captured_per_zone_per_time])[z,:]))
		end

		if setup["ModelLFSC"] == 1 && setup["ModelSyntheticFuels"] == 1
			tempSynfuel_Production_Capture = tempSynfuel_Production_Capture + sum(inputs["omega"].* (value.(EP[:eSyn_Fuels_CO2_Capture_Per_Zone_Per_Time])[z,:]))
			tempSynfuel_Production_Consumption = tempSynfuel_Production_Consumption - sum(inputs["omega"].* (value.(EP[:eSyn_Fuel_CO2_Cons_Per_Zone_Per_Time])[z,:]))
		end

		if setup["ModelNGSC"] == 1 && setup["ModelSyntheticNG"] == 1
			tempSyn_NG_Production_Capture = tempSyn_NG_Production_Capture + sum(inputs["omega"].* (value.(EP[:eSyn_NG_CO2_Capture_Per_Zone_Per_Time])[z,:]))
			tempSyn_NG_Production_Consumption = tempSyn_NG_Production_Consumption - sum(inputs["omega"].* (value.(EP[:eSyn_NG_CO2_Cons_Per_Zone_Per_Time])[z,:]))
		end

		if setup["ModelCO2Pipelines"] == 1
			tempCO2_Pipeline_Import = tempCO2_Pipeline_Import + sum(inputs["omega"].* (value.(EP[:ePipeZoneCO2Demand])[:,z]))
		end

		if setup["ModelCO2Storage"] == 1
			tempCO2_Storage = tempCO2_Storage - sum(inputs["omega"].* (value.(EP[:eCO2_Injected_per_zone])[z,:]))
		end

		tempCTotal = tempPower_CCS + tempH2_CCS + tempDAC_Capture + tempDAC_Fuel_CCS + tempBiorefinery_Capture + tempSynfuel_Production_Capture + tempSynfuel_Production_Consumption + tempSyn_NG_Production_Capture + tempSyn_NG_Production_Consumption + tempCO2_Pipeline_Import + tempCO2_Storage

		dfCost[!,Symbol("Zone$z")] = [tempPower_CCS, tempH2_CCS, tempDAC_Capture, tempDAC_Fuel_CCS, tempBiorefinery_Capture, tempSynfuel_Production_Capture, tempSynfuel_Production_Consumption, tempSyn_NG_Production_Capture,  tempSyn_NG_Production_Consumption,  tempCO2_Pipeline_Import, tempCO2_Storage, tempCTotal]
	end

	CSV.write(string(path,sep,"CSC_storage_balance_zone.csv"), dfCost)

end