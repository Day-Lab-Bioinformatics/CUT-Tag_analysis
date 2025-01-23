#!/bin/bash

## Launch_looplength.5.0_G4Catchall.sh
## Created by Adrianna Vandeuren on 08/06/2023
## This script serves to launch the looplength.5.0 jobs in parallel on all files.
## It will significantly reduce the runtime needed for this analysis. 

## Define the path to your duplicate removed files
g4catchallPath="/path/to/project/directory/G4Catchall_output"

cd $g4catchallPath

## Define the path to your job to be submitted
jobPath="/path/to/job/script"

## Loop over all the files in the folder defined in your fastqPath
for file in *_all.bed
do
    ## Define the output prefix; -F is where the sample name will be cut
    OUTNAME=`ls ${file} | awk -F'_all.bed' '{print $1}'`

    ## Checkpoint to test code so far 
    echo "$OUTNAME"

    ## --export means that you pass on the defined arguments to the script you call here
    sbatch --export=NAME=${OUTNAME} ${jobPath}/looplength_5.0_G4Catchall_Job.sh

done


