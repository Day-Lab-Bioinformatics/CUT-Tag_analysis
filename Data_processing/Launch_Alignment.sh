#!/bin/bash

## Launch_ALignment.sh
## Created by Adrianna Vandeuren on 10/06/2022
## This script serves to launch the Alignment jobs in parallel on all files.
## It will significantly reduce the runtime needed for this analysis. 

# Activate the necessary tools and environments for the Format Conversion. 
module load anaconda3
conda init
source activate cut_N_tag

## Define the path to your job to be submitted
jobPath="/path/to/job/script"

## Define the path to your sequencing results
fastqPath="/path/to/fastq/files"

cd $fastqPath

## Loop over all the files in the folder defined in your fastqPath
for file in *_R1_001.fastq.gz
do
    ## Define the output prefix; -F is where the sample name will be cut
    OUTNAME=`ls ${file} | awk -F'_R1_001.fastq.gz' '{print $1}'`
    
    ## Checkpoint to test code so far 
    echo "$OUTNAME"

    ## Define the read suffixes
    READ1=`ls ${OUTNAME}_R1_001.fastq.gz`
    READ2=`ls ${OUTNAME}_R2_001.fastq.gz`

    ## Checkpoint to test code so far
    ## echo "$READ1 $READ2"

    ## --export means that you pass on the defined arguments to the script you call here
    sbatch --export=R1=${READ1},R2=${READ2},NAME=${OUTNAME} ${jobPath}/Alignment_Job.sh

done




