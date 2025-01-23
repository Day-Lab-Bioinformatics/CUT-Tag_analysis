#!/bin/bash

## Annotation_Job.sh
## Created by Adrianna Vandeuren on 08/08/2023
## This script serves to easily intersect your files with the chromatin mark annotation file.

module load anaconda3
conda init
source activate cut_N_tag

## Define the path to your High Quality narrowPeak file
hqPath="/path/to/project/directory/High-Quality"

cd $hqPath

## Define the path to your job to be submitted
jobPath="/path/to/job/script"

## Loop over all the files in the folder defined in your fastqPath
for file in *.bed
do
    ## Define the output prefix; -F is where the sample name will be cut
    OUTNAME=`ls ${file} | awk -F'.bed' '{print $1}'`

    ## Checkpoint to test code so far 
    echo "$OUTNAME"

    bedtools intersect -wo -a ${OUTNAME}.bed -b ${jobPath}/annotation_file.bed >${OUTNAME}_annotated.bed 

done


