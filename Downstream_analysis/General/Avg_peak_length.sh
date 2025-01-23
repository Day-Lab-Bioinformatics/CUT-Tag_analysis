#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=Peak_len
#SBATCH --time=00:20:00
#SBATCH --mem=1G
#SBATCH --partition=short


## Avg_peak_length.sh
## Created by Adrianna Vandeuren on 11/17/2022
## Adapted by Adrianna Vandeuren on 03/21/2024
## Run this on the narrowPeak files to obtain the average peak length so you can calculate the G4 coverage

## Define the path of where your files of interest are located
projPath="/path/to/project/directory"

cd $projPath

## Create the results file
touch Avg_peak_length.txt

for file in *.bed
do 
    ## Extract the name
    NAME=`ls ${file} | awk -F'.bed' '{print $1}'`
    ## Calculate the average peak length
    AVG=`ls ${file} | awk '{ a+=$3-$2 ; count++ } END { print a/count }' ${file}`
    ## Add a line to the results file with the name of the file you analyzed followed by the average
    echo -e $NAME '\t' $AVG >> Avg_peak_length.txt
done
