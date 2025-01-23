#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=AV_alignment
#SBATCH --time=24:00:00
#SBATCH --mem=150G
#SBATCH --partition=short

## SEACR_calling.sh
## Script Created by Adrianna Vandeuren 02/06/2024
## Define the path where your data is saved

projPath="/path/to/project/directory"

blrPath="/path/to/project/directory/alignment/blacklistRemoved"

mkdir -p $projPath/peakCalling/SEACR


## Activate necessary environment
module load anaconda3
conda init
source activate cut_N_tag


## Define the filenames of your bedgraph files to make analysis of multiple files easier
## Define suffixe

Suffix=".bedgraph"

for File in $blrPath*$Suffix
do
    ## Remove the path from the filename and assing to pathRemoved
    pathRemoved="${File/$blrPath/}"
    ## Remove the suffix from $pathRemoved and assign to sampleName
    sampleName="${pathRemoved/$Suffix/}"
    ## Print $sampleName to see what it contains after removing the path, just a control
    echo $sampleName

    seacr="/path/to/job/script/SEACR-master/SEACR_1.3.sh"


    bash $seacr $blrPath/${sampleName}.bedgraph 0.01 non stringent $projPath/peakCalling/SEACR/${sampleName}_seacr_top0.01.peaks

done



