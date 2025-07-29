#!/bin/bash
## Launch_consensus_peaks_slurm.sh
## Created by Adrianna Vandeuren on 06/27/2025
## Created for consensus peaks analysis using SLURM
## This script submits separate SLURM jobs for each treatment group

## Define the path to your narrowPeak files  
peaksPath="/path/to/peak/files"
cd $peaksPath

## Define the path to your job script
jobPath="/path/to/scripts"

## Extract unique treatment groups from filenames
groups=$(ls *_peaks.narrowPeak | sed 's/_[0-9]*_peaks\.narrowPeak$//' | sort -u)

echo "Detected treatment groups:"
for group in $groups
do
    echo "  - $group"
done
echo ""

## Submit SLURM job for each treatment group
for group in $groups
do
    echo "Submitting SLURM job for $group..."
    
    ## Submit job with group name as parameter
    sbatch --export=GROUP=${group},PEAKS_PATH=${peaksPath} ${jobPath}/consensus_peaks_job.sh
    
done

echo "All SLURM jobs submitted!"
