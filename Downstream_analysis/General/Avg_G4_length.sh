#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=AV_peak
#SBATCH --time=00:20:00
#SBATCH --mem=10G
#SBATCH --partition=short

## Avg_G4_length.sh
## Created by Adrianna Vandeuren on 11/17/2022
## Adapted by Adrianna Vandeuren on 07/20/2023
## Run the script after the G4Catchall analysis to figure out how long the G4s are on average for each target.

## Define the path of where your files of interest are located
projPath="/path/to/project/directory/G4Catchall_output"

cd $projPath

## Create the results file
touch Avg_G4_length.txt


for file in *_all.bed 
do 
    ## Extract file name
    NAME=`ls ${file} | awk -F'_all.bed' '{print $1}'`
    ## Calculate the average length of the G4 per file
    AVG=`ls ${file} | awk '{ total += $4; count++ } END { print total/count }' ${file}`
    ## Add a line to the results file containing the file name followed by the average
    echo -e $NAME '\t' $AVG >> Avg_G4_length.txt
done


