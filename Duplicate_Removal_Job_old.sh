#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=Duplicate_removal
#SBATCH --time=4:00:00
#SBATCH --mem=10G
#SBATCH --partition=short
#SBATCH --cpus-per-task=8


## Duplicate_Removal_Job.sh
## Created by Adrianna Vandeuren on 10/07/2022
## This script will be called by Launch_Duplicate_Removal.sh, you do not need to run it separately. 

## Load the necessary modules 
## Picard needs java to run. I created a Java environment that needs to be called. 
module load anaconda3
source activate Java 

## Define project path
projPath="/path/to/project/directory"

## Create output directory 
mkdir -p $projPath/removeDuplicate/picard_summary

## Sort by coordinate
picard SortSam I=$projPath/sam/${INPUT}.sam O=$projPath/sam/${INPUT}.sorted.sam SORT_ORDER=coordinate

## mark duplicates
picard MarkDuplicates I=$projPath/sam/${INPUT}.sorted.sam O=$projPath/removeDuplicate/${INPUT}.sorted.dupMarked.sam METRICS_FILE=$projPath/removeDuplicate/picard_summary/${INPUT}.dupMark.txt

## remove duplicates
picard MarkDuplicates I=$projPath/sam/${INPUT}.sorted.sam O=$projPath/removeDuplicate/${INPUT}.sorted.rmDup.sam REMOVE_DUPLICATES=true METRICS_FILE=$projPath/removeDuplicate/picard_summary/${INPUT}_picard.rmDup.txt


