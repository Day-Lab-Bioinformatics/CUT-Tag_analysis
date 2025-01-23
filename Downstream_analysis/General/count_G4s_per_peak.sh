#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=GPP
#SBATCH --time=00:20:00
#SBATCH --mem=1G
#SBATCH --partition=short

## count_G4s_per_peak.sh
## Created by Adrianna Vandeuren on 11/18/2022
## Adapted by Adrianna Vandeuren on 07/20/2023

## Define the path of where your files of interest are located
projPath="/path/to/project/directory/G4Catchall_output"


for file in $projPath/*_all.bed
do
    ## Extract the file name 
    NAME=`ls ${file} | awk -F'_all.bed' '{print $1}'`
    ## print the name in column one as well as the amount of times this name occurs in the file
    awk '{print $1}' ${file} | uniq -c >> ${NAME}_GPP.txt
done  



