#!/bin/bash

## Launch_Format_Conversion.sh
## Created by Adrianna Vandeuren on 10/17/2022
## This script serves to launch the format conversion jobs in parallel on all files.
## It will significantly reduce the runtime needed for this analysis. 

# Activate the necessary tools and environments for the Format Conversion. 
module load anaconda3
conda init
source activate cut_N_tag


## Define the path to your duplicate removed files
rmdupPath="/path/to/project/directory/alignment/removeDuplicate"

cd $rmdupPath

## Define the path to your job to be submitted
jobPath="/path/to/job/script"

## Loop over all the files in the folder defined in your fastqPath
for file in *.sorted.rmDup.sam 
do
    ## Define the output prefix; -F is where the sample name will be cut
    OUTNAME=`ls ${file} | awk -F'.sorted.rmDup.sam' '{print $1}'`

    ## Checkpoint to test code so far 
    echo "$OUTNAME"

    ## --export means that you pass on the defined arguments to the script you call here
    sbatch --export=NAME=${OUTNAME} ${jobPath}/Format_Conversion_Job.sh

done


