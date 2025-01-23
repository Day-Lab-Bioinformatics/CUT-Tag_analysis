#!/bin/bash

## Launch_Peak_Calling.sh
## Created by Adrianna Vandeuren on 10/26/2022
## This script serves to launch the format conversion jobs in parallel on all files.
## It will significantly reduce the runtime needed for this analysis. 

## Define the path to your duplicate removed files
blrPath="/path/to/project/directory/alignment/blacklistRemoved"

projPath="/path/to/project/directory"

mkdir -p ${projPath}/peakCalling/
mkdir -p ${projPath}/bamCoverage/

cd $blrPath

## Define the path to your job to be submitted
jobPath="/path/to/job/script"

## Loop over all the files in the folder defined in your fastqPath
for file in *_blr.bam
do
    ## Define the output prefix; -F is where the sample name will be cut
    OUTNAME=`ls ${file} | awk -F'_blr.bam' '{print $1}'`

    ## Checkpoint to test code so far 
    echo "$OUTNAME"

    ## --export means that you pass on the defined arguments to the script you call here
    sbatch --export=NAME=${OUTNAME} ${jobPath}/Peak_Calling_Job.sh

done


