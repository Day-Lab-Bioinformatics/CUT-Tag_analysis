#!/bin/bash

## Launch_G4Intersect.sh
## Created by Annika Salpukas on 9/16/24.
## This script serves to launch the G4Intersect jobs in parallel on all files.
## It will significantly reduce the runtime needed for this analysis. 

## Define the path to raw files
breakendsPath="/path/to/100bp_extended/breakend/files"

cd $breakendsPath

## Define the path to your job to be submitted
jobPath="/path/to/job/script"

## Define path to g4catchall file
g4catchall='/path/to/whole/genome/G4Catchall/file'

## Loop over all the files in the folder defined in your fastqPath
for file in *.breakends_ext100.bed
do
    ## Define the output prefix; -F is where the sample name will be cut
    OUTNAME=`ls ${file} | awk -F'.breakends_ext100.bed' '{print $1}'`
    
    ## Define input/output file paths
    outfile="/path/to/output/${OUTNAME}_intersects.bed"

    ## Checkpoint to test code so far 
    echo "Running bedtools intersect on ${OUTNAME} --> ${outfile}"

    ## --export means that you pass on the defined arguments to the script you call here
    sbatch --export=ANCHOR=${file},G4=${g4catchall},OUTFILE=${outfile} ${jobPath}/G4Intersect_Job.sh

done