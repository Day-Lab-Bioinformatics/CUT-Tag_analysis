#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=format
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --partition=short
#SBATCH --cpus-per-task=8


## Format_Conversion_Job.sh
## Script created by Adrianna Vandeuren on 07/21/2022
## Script adapted by Adrianna Vandeuren on 10/17/2022
## Launch_Format_Conversion.sh will call this script, you do not need to run it on it's own. 

# Activate the necessary tools and environments for the Format Conversion. 
module load anaconda3
conda init
source activate cut_N_tag


## Define project path
projPath="/path/to/project/directory/alignment"
jobPath="/path/to/job/script"

## Define output paths
bamPath="/path/to/project/directory/alignment/bam"

## Filter and keep the mapped read pairs, change format to bam
samtools view -bS -F 4 ${NAME}.sorted.rmDup.sam >$bamPath/${NAME}.mapped.bam

## Intesect the bam files with the blacklist file. 
#bedtools intersect -v -abam $bamPath/${NAME}.mapped.bam -b $jobpath/ENCFF200UUD.bed >$projPath/blacklistRemoved/${NAME}_hg19.fltd.bam


