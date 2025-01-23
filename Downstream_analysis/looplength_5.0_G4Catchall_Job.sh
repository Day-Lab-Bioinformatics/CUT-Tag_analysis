#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=Looplength
#SBATCH --time=00:20:00
#SBATCH --mem=2G
#SBATCH --partition=short


## looplength_5.0_G4Catchall_Job.sh
## Script created by Adrianna Vandeuren on 08/06/2023
## This script will be called by Launch_looplength.5.0.sh, you don't need to run it separately.

jobPath="/path/to/job/script"

python ${jobPath}/looplength_qaudruplex_5.0_G4Catchall.py ${NAME}_all.bed
