#!/bin/bash

## Launch_FASTQC.sh
## Created by Adrianna Vandeuren on 08/02/2023
## This script serves to launch the FASTQC jobs in parallel on all files.
## It will significantly reduce the runtime needed for this analysis. 


## Define the path to your sequencing results
projPath="/path/to/project/directory"
fastqPath="/path/to/fastq/files"

cd $fastqPath

## Loop over all the files in the folder defined in your fastqPath
for file in *_R1_001.fastq.gz
do
    ## Define the output prefix; -F is where the sample name will be cut
    OUTNAME=`ls ${file} | awk -F'_R1' '{print $1}'`

    ## Checkpoint to test code so far 
    echo "$OUTNAME"

    ## Define the read suffixes
    READ1=`ls ${OUTNAME}_R1_001.fastq.gz`
    READ2=`ls ${OUTNAME}_R2_001.fastq.gz`

    ## Checkpoint to test code so far
    ## echo "$READ1 $READ2"

    mkdir -p ${projPath}/fastqFileQC/${OUTNAME}

    ## --export means that you pass on the defined arguments to the script you call here
    sbatch --export=R1=${READ1},R2=${READ2},NAME=${OUTNAME} /path/to/job/script/FASTQC_Job.sh

done
