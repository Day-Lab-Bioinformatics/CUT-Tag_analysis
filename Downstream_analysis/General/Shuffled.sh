#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=shuffle
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --partition=short


## Shuffled.sh
## Script created by Adrianna Vandeuren on 08/25/2022
## Run script after high quality peak identification
## Goal: generate size matched shuffled files that also takes the chromosome and blacklist information into account. 

module load bedtools

## Adjust path to where the files of interest are located.
hqPath="/path/to/project/directory/High_Quality"

## Define suffixes 
cd $hqPath

sampleSuffix=".narrowPeak"

for sampleInFile in *$sampleSuffix
do
        ## Remove the path from the filename and assing to pathRemoved
        pathRemoved="${sampleInFile/$hqPath/}"
        # Remove the left-read suffix from $pathRemoved and assign to sampleName
        sampleName="${pathRemoved/$sampleSuffix/}"
        # Print $sampleName to see what it contains after removing the path, just a control => I commented it out
        echo $sampleName

	bedtools shuffle -g /path/to/job/script/hg19.chrom.sizes -seed 123 -chrom -excl /path/to/job/script/ENCFF200UUD.bed -i ${sampleName}.narrowPeak | sort -k1,1 -k2,2n >${sampleName}.shuffle.narrowPeak

done




