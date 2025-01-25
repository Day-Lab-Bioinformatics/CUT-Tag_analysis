#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=G4_inter
#SBATCH --time=00:30:00
#SBATCH --mem=10G
#SBATCH --partition=short


## G4Intersect_Job.sh
## Script created by Annika Salpukas on 9/16/24
## This script will be called by Launch_G4Intersect.sh, you don't need to run it separately.

source /etc/profile.d/modules.sh

module load bedtools

bedtools intersect -wo -a $ANCHOR -b $G4 > $OUTFILE