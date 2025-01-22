#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=Genome_Assembly
#SBATCH --time=10:00:00
#SBATCH --mem=10G
#SBATCH --partition=short

## Genome_Assembly.sh
## Script Created by Adrianna Vandeuren 06/06/2023
## Goal assemble the genome of interest for analysis
## Adapt the relative paths as needed

## Go to the directory where you want to store the data
cd bowtie2_ref_genome/hg19

## Download the bowtie hg19 reference genome
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
gunzip hg19.fa.gz

date
echo "running hg19 build"  
### This is a relative path, adjust as needed
hg19Ref="bowtie2_ref_genome/hg19"
  
## Build the Drosophila Spike-in reference genome 
bowtie2-build ${hg19Ref}/hg19.fa ${hg19Ref}/hg19

