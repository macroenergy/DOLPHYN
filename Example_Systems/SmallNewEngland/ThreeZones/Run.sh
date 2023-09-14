#!/bin/bash
#SBATCH --job-name=ThreeZones        # create a short name for your job
#SBATCH --nodes=1              # node count
#SBATCH --ntasks=1             # total number of tasks across all nodes
#SBATCH --cpus-per-task=8          # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=10G          # memory per cpu-core
#SBATCH --time=12:00:00           # total run time limit (HH:MM:SS)
#SBATCH --output="test.out"
#SBATCH --error="test.err"
# #SBATCH --mail-type=FAIL          # notifications for job done & fail
# #SBATCH --mail-user=sc87@princeton.edu # send-to address
# Initialize module
source /etc/profile
module load julia/1.8.5
module load gurobi/gurobi-1000
julia --project=. /home/gridsan/larmstrong/DOLPHYN_modeling/DOLPHYN-dev/Example_Systems/SmallNewEngland/ThreeZones/Run.jl
# julia /home/gridsan/larmstrong/DOLPHYN_modeling/DOLPHYN-dev/Example_Systems/SmallNewEngland/ThreeZones/Run.jl
date