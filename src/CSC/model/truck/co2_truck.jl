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
    co2_truck(EP::Model, inputs::Dict, setup::Dict)

"""
function co2_truck(EP::Model, inputs::Dict, setup::Dict)

    println("Carbon Truck Module")

    # investment variables expressions and related constraints for carbon trucks
    EP = co2_truck_investment(EP::Model, inputs::Dict, setup::Dict)

    # Operating variables, expressions and constraints related to carbon trucks
    EP = co2_truck_all(EP, inputs, setup)

    # Include LongDurationTruck only when modeling representative periods and long-duration truck
    if setup["OperationWrapping"] == 1 && !isempty(inputs["CO2_TRUCK_LONG_DURATION"])
        EP = co2_long_duration_truck(EP, inputs, setup)
    end

    return EP
end