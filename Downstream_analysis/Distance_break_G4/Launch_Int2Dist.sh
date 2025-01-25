#!/bin/bash

## Launch_Int2Dist.sh
## Created by Annika Salpukas on 9/25/24.
## This script serves to launch the Int2Dist jobs in parallel on all files.

## Define the path to raw files
intersectPath="/path/to/intersects"

cd $intersectPath

## Define the path to your job to be submitted
jobPath="/path/to/job/script"

## Loop over all the files in the folder defined in your fastqPath
for file in *_intersects.bed
do
    ## Define the output prefix; -F is where the sample name will be cut
    OUTNAME=`ls ${file} | awk -F'_intersects.bed' '{print $1}'`
    
    ## Define input/output file paths
    outfile="../distances/${OUTNAME}_distances.bed"

    ## Checkpoint to test code so far 
    echo "Running int2dist on ${OUTNAME}"

    ## --export means that you pass on the defined arguments to the script you call here
    sbatch --export=INTERSECTS=${file},OUTFILE=${outfile},JOBPATH=${jobPath} ${jobPath}/Int2Dist_Job.sh

done