#!/bin/bash

## Launch_Duplicate_Removal.sh
## Created by Adrianna Vandeuren on 10/07/2022
## This script serves to launch the Duplicate Removal jobs in parallel on all files.
## It will significantly reduce the runtime needed for this analysis. 


## Define the path to your sequencing results
samPath="/path/to/project/directory/alignment/sam"

cd $samPath

## Define the path to your job to be submitted
jobPath="/path/to/job/script"

## Loop over all the files in the folder defined in your fastqPath
for file in *.sam
do
    ## Define the output prefix; -F is where the sample name will be cut
    INNAME=`ls ${file} | awk -F'.sam' '{print $1}'`

    ## Checkpoint to test code so far 
    echo "$INNAME"
    

    ## --export means that you pass on the defined arguments to the script you call here
    sbatch --export=INPUT=${INNAME} ${jobPath}/Duplicate_Removal_Job_old.sh

done


