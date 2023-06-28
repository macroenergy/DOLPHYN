#!/bin/bash
#SBATCH --job-name=FRCC_2019_5GW_Flex_cap              # create a short name for your job
#SBATCH --nodes=1                           # node count
#SBATCH --ntasks=1                          # total number of tasks across all nodes
#SBATCH --cpus-per-task=2                   # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=5G                    # memory per cpu-core
#SBATCH --time=12:00:00                     # total run time limit (HH:MM:SS)
#SBATCH --output="test.out"
#SBATCH --error="test.err"
#SBATCH --mail-type=FAIL                    # notifications for job done & fail
#SBATCH --mail-user=dharik@mit.edu          # send-to address

source /etc/profile
module load julia/1.7.3

export GUROBI_HOME="/home/gridsan/dmallapragada/gurobi912/linux64"

julia --project=/home/gridsan/dmallapragada/Time_matching/DOLPHYN-dev/DOLPHYNJulEnv Run.jl

date
