#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=Peak
#SBATCH --time=01:00:00
#SBATCH --mem=10G
#SBATCH --partition=short


## Peak_Calling_Job.sh
## Script created by Adrianna Vandeuren on 10/26/2022
## This script will be called by Launch_Peak_Calling.sh, you don't need to run it separately.

module load anaconda3
conda init
source activate MACS2

projPath="/path/to/project/directory"

## Define path
blrPath="/path/to/project/directory/alignment/blacklistRemoved"

	
## First the files need to be indexed
samtools index ${NAME}_blr.bam

## This tool takes an alignment of reads or fragments as input (BAM file) and generates a coverage track (bigWig or bedGraph) as output. 
bamCoverage --bam ${NAME}_blr.bam --binSize 5 --normalizeUsing RPGC --effectiveGenomeSize 2827437033 -o ${projPath}/bamCoverage/${NAME}.hg19.bw 

## If the code above does not seem to work, remove RPGC and genome size 
#bamCoverage --bam ${NAME}_blr.bam --binSize 5 -o ${projPath}/bamCoverage/${NAME}.hg19.bw

## peakCalling using MACS2 as done in Jing's data analysis
macs2 callpeak -t ${NAME}_blr.bam -n ${NAME}  -g hs --bdg --outdir $projPath/peakCalling





