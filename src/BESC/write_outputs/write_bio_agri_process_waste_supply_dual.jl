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

function write_bio_agri_process_waste_supply_dual(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)
	
	T = inputs["T"]     # Number of time steps (hours)
	Z = inputs["Z"]     # Number of zones

	omega = inputs["omega"] # Time step weights

	dfAgriProcessWasteSupplyBalanceDual = DataFrame(Zone = 1:Z)
	dual_values = transpose(dual.(EP[:cAgriProcessWasteBiomassBalance]) ./ omega)

	dfAgriProcessWasteSupplyBalanceDual=hcat(dfAgriProcessWasteSupplyBalanceDual, DataFrame(dual_values, :auto))
	rename!(dfAgriProcessWasteSupplyBalanceDual,[Symbol("Zone");[Symbol("t$t") for t in 1:T]])

	CSV.write(string(path,sep,"BESC_agri_process_waste_supply_balance_dual.csv"), dftranspose(dfAgriProcessWasteSupplyBalanceDual, false), writeheader=false)

end