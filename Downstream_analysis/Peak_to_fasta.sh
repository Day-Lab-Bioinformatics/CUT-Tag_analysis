#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=AV_peak
#SBATCH --time=01:00:00
#SBATCH --mem=10G
#SBATCH --partition=short


## Peak_to_fasta.sh
## Script created by Adrianna Vandeuren on 08/25/2022
## Run script after high quality peak identification
## Goal go from a bed file that list start and end positions to a fasta file containing sequences.  

module load bedtools

## Adjust path to where the files of interest are located.
hqPath="/path/to/project/directory/High_Quality"
mkdir -p ${hqPath}/Fasta

cd $hqPath

## Define suffixes 
sampleSuffix=".narrowPeak"

for sampleInFile in *$sampleSuffix
do
        ## Remove the path from the filename and assing to pathRemoved
        pathRemoved="${sampleInFile/$hqPath/}"
        # Remove the left-read suffix from $pathRemoved and assign to sampleName
        sampleName="${pathRemoved/$sampleSuffix/}"
        # Print $sampleName to see what it contains after removing the path, just a control => I commented it out
        echo $sampleName

	bedtools getfasta -fi /path/to/job/script/hg19.fa  -bed $projPath/${sampleName}.narrowPeak -fo $projPath/Fasta/${sampleName}.fa

done




