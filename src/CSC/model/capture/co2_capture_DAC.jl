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
	co2_capture_DAC(EP::Model, inputs::Dict, UCommit::Int, Reserves::Int)

The co2_capture_DAC module creates decision variables, expressions, and constraints related to direct air carbon capture technologies

"""

function co2_capture_DAC(EP::Model, inputs::Dict,setup::Dict)

	#Rename CO2Capture dataframe
	dfDAC = inputs["dfDAC"]

	T = inputs["T"]     # Number of time steps (hours)
	Z = inputs["Z"]     # Number of zones
	
	CO2_CAPTURE_DAC = inputs["CO2_CAPTURE_DAC"]
	
	#Define start subperiods and interior subperiods
	START_SUBPERIODS = inputs["START_SUBPERIODS"]
	INTERIOR_SUBPERIODS = inputs["INTERIOR_SUBPERIODS"]
	hours_per_subperiod = inputs["hours_per_subperiod"] #total number of hours per subperiod

	###############################################################################################################################
	##Expressions

	#CO2 Balance expressions
	@expression(EP, eDAC_CO2_Captured[t=1:T, z=1:Z],
	sum(EP[:vDAC_CO2_Captured][k,t] for k in intersect(CO2_CAPTURE_DAC, dfDAC[dfDAC[!,:Zone].==z,:][!,:R_ID])))

	#ADD TO CO2 BALANCE
	EP[:eCaptured_CO2_Balance] += eDAC_CO2_Captured

	#Power Balance
	# If ParameterScale = 1, power system operation/capacity modeled in GW, no need to scale as MW/ton = GW/kton 
	# If ParameterScale = 0, power system operation/capacity modeled in MW
	
	#Power consumption by DAC
	@expression(EP, ePower_Balance_DAC[t=1:T, z=1:Z],
	sum(EP[:vPower_DAC][k,t] for k in intersect(CO2_CAPTURE_DAC, dfDAC[dfDAC[!,:Zone].==z,:][!,:R_ID])))

	#Add to power balance to take power away from generated
	EP[:ePowerBalance] += -ePower_Balance_DAC

	##For CO2 Polcy constraint right hand side development - power consumption by zone and each time step
	EP[:eCSCNetpowerConsumptionByAll] += ePower_Balance_DAC

	#Power produced by DAC
	@expression(EP, ePower_Produced_Balance_DAC[t=1:T, z=1:Z],
	sum(EP[:vPower_Produced_DAC][k,t] for k in intersect(CO2_CAPTURE_DAC, dfDAC[dfDAC[!,:Zone].==z,:][!,:R_ID])))

	#Add to power balance to add power produced by DAC
	EP[:ePowerBalance] += ePower_Produced_Balance_DAC
	EP[:eCSCNetpowerConsumptionByAll] -= ePower_Produced_Balance_DAC

	###############################################################################################################################
	##Constraints
	#Power consumption constraint
	@constraint(EP,cPower_Consumption_DAC[k in CO2_CAPTURE_DAC, t = 1:T], EP[:vPower_DAC][k,t] == EP[:vDAC_CO2_Captured][k,t] * dfDAC[!,:etaPCO2_MWh_per_tonne][k])

	#Power production constraint
	@constraint(EP,cPower_Production_DAC[k in CO2_CAPTURE_DAC, t = 1:T], EP[:vPower_Produced_DAC][k,t] == EP[:vDAC_CO2_Captured][k,t] * dfDAC[!,:Power_Production_MWh_per_tonne][k])

	#Include constraint of min capture operation
	@constraint(EP,cMin_CO2_Captured_DAC_per_type_per_time[k in CO2_CAPTURE_DAC, t=1:T], EP[:vDAC_CO2_Captured][k,t] >= EP[:vCapacity_DAC_per_type][k] * dfDAC[!,:CO2_Capture_Min_Output][k])

	#Max carbon capture per resoruce type k at hour T
	@constraint(EP,cMax_CO2_Captured_DAC_per_type_per_time[k in CO2_CAPTURE_DAC, t=1:T], EP[:vDAC_CO2_Captured][k,t] <= EP[:vCapacity_DAC_per_type][k] * inputs["CO2_Capture_Max_Output"][k,t] )


	#Define start subperiods and interior subperiods

	@constraint(EP, cMax_Rampup_Start_DAC[k in CO2_CAPTURE_DAC, t in START_SUBPERIODS], (EP[:vDAC_CO2_Captured][k,t] - EP[:vDAC_CO2_Captured][k,(t + hours_per_subperiod-1)]) <= dfDAC[!,:Ramp_Up_Percentage][k] * EP[:vCapacity_DAC_per_type][k])

	@constraint(EP, cMax_Rampup_Interior_DAC[k in CO2_CAPTURE_DAC, t in INTERIOR_SUBPERIODS], (EP[:vDAC_CO2_Captured][k,t] - EP[:vDAC_CO2_Captured][k,t-1]) <= dfDAC[!,:Ramp_Up_Percentage][k] * EP[:vCapacity_DAC_per_type][k])

	@constraint(EP, cMax_Rampdown_Start_DAC[k in CO2_CAPTURE_DAC, t in START_SUBPERIODS], (EP[:vDAC_CO2_Captured][k,(t + hours_per_subperiod-1)] - EP[:vDAC_CO2_Captured][k,t]) <= dfDAC[!,:Ramp_Down_Percentage][k] * EP[:vCapacity_DAC_per_type][k])

	@constraint(EP, cMax_Rampdown_Interior_DAC[k in CO2_CAPTURE_DAC, t in INTERIOR_SUBPERIODS], (EP[:vDAC_CO2_Captured][k,t-1] - EP[:vDAC_CO2_Captured][k,t]) <= dfDAC[!,:Ramp_Down_Percentage][k] * EP[:vCapacity_DAC_per_type][k])

	return EP

end



