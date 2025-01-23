#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=Alignment
#SBATCH --time=5:00:00
#SBATCH --mem=10G
#SBATCH --partition=short
#SBATCH --cpus-per-task=8

## Alignment_Job.sh
## Created by Adrianna Vandeuren on 10/06/2022
## This script will be called by Launch_Alignment.sh, you do not need to run it separately. 
## It serves to align your sequencing output to the hg19 and drosophila reference genomes

## Activate necessary environment to be able to load bowtie2
module load anaconda3
conda init
source activate cut_N_tag

## Define the path to the hg19 reference genome
refPath="/path/to/hg19"

## Define the path to the drosophila reference genome (Spike-in genome)
spikeRefPath="/path/to/dm6"

## Define your project path 
projPath="/path/to/project/directory"

## Create directories to store the results
mkdir -p ${projPath}/alignment/sam/bowtie2_summary
mkdir -p ${projPath}/alignment/bam
mkdir -p ${projPath}/alignment/bed
mkdir -p ${projPath}/alignment/bedgraph

## Align your reads to hg19
date
echo "Aligning ${NAME} to hg19" 

bowtie2 -p 8 -x ${refPath}/hg19 -5 19 -q  -1 $R1 -2 $R2 --fast -S ${projPath}/alignment/sam/${NAME}_bowtie2.sam &> ${projPath}/alignment/sam/bowtie2_summary/${NAME}_bowtie2.txt

## Align your read to the spike-In genome 

date
echo "Aligning ${NAME} to Drosophila"

bowtie2 --no-overlap --no-dovetail -p 8 -x ${spikeRefPath}/SpikeIn -5 19 -q  -1 $R1 -2 $R2 --fast -S ${projPath}/alignment/sam/${NAME}_bowtie2_SpikeIn.sam &> ${projPath}/alignment/sam/bowtie2_summary/${NAME}_bowtie2_SpikeIn.txt

date
echo "Running seqDepth Spike-In"

## Calculate values for Spike-In calibration
seqDepthDouble=`samtools view -F 0x04 $projPath/alignment/sam/${NAME}_bowtie2_SpikeIn.sam | wc -l`
seqDepth=$((seqDepthDouble/2))
echo $seqDepth >$projPath/alignment/sam/bowtie2_summary/${NAME}_bowtie2_spikeIn.seqDepth

echo "Ran to completion"

