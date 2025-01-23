#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=Avg_GPP
#SBATCH --time=00:20:00
#SBATCH --mem=1G
#SBATCH --partition=short

## Created by Adrianna Vandeuren on 11/17/2022
## Adapted by Adrianna Vandeuren on 07/20/2023
## Run the script after the G4Catchall analysis and after running "count_G4s_per_peak.sh" to figure out how many G4s are in each peak.

## Define the path of where your files of interest are located
projPath="/path/to/project/directory/G4Catchall_output"

## Create the results file
touch $projPath/Avg_G4s_per_peak.txt

cd $projPath

for file in *_GPP.txt
do 
    ## Extract the file name
    NAME=`ls ${file} | awk -F'_GPP.txt' '{print $1}'`
    ## Calculate the average G4s per peak
    AVG=`ls ${file} | awk '{ total += $1; count++ } END { print total/count }' ${file}`
    ## Add a line to the results file with the name of the file you analyzed followed by the average
    echo -e $NAME '\t' $AVG >> Avg_G4s_per_peak.txt
done


