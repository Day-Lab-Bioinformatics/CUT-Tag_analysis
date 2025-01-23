#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=format
#SBATCH --time=02:10:00
#SBATCH --mem=1G
#SBATCH --partition=short
#SBATCH --cpus-per-task=8


## Format_Conversion_Job_Scaled.sh
## Script created by Adrianna Vandeuren on 07/21/2022
## Script adapted by Adrianna Vandeuren on 02/26/2024
## Launch_Format_Conversion_Scaled.sh will call this script, you do not need to run it on it's own. 

# Activate the necessary tools and environments for the Format Conversion. 
module load anaconda3
conda init
source activate cut_N_tag


## Define project path
projPath="/path/to/project/directory"
jobPath="/path/to/job/script"
seqDepthPath="/path/to/project/directory/alignment/sam/bowtie2_summary"

## Define output paths
bamPath="/path/to/project/directory/alignment/bam"

## Filter and keep the mapped read pairs, change format to bam
samtools view -bS -F 4 ${NAME}.sorted.rmDup.sam >$bamPath/${NAME}.mapped.bam

## Define seqDepth
## Store the seqDepth value found in the spikeIn.seqDepth files in the seqDepth variable 
read seqDepth < $seqDepthPath/${NAME}_spikeIn.seqDepth
echo $seqDepth

if [[ "$seqDepth" -gt "1" ]]; then
    ## Calculate scaling factor. If your seqDepth is much smaller than 10 000 or much bigger than that, you might want to adapt the arbitrary value of 10 000 to match your data better. I think a scaling factor between 1 and 10 is more convenient to work with. 
    scale_factor=`echo "10000 / $seqDepth" | bc -l`
    echo "Scaling factor for ${NAME} is: $scale_factor!"

fi 

## re-index bam files
samtools index $bamPath/${NAME}.mapped.bam


## NORMALIZATION USING SCALING FACTOR
## Convert bam files to bedgraph format using the scaling factor and intersect with the blacklist file. 
## -b = bam input file ; -o = output file ; -of = output format ; -bs = bin size ; -e extend reads to 150 ; -bl = blacklist file
bamCoverage -b $bamPath/${NAME}.mapped.bam -o $projPath/alignment/blacklistRemoved/${NAME}_scaled.bedgraph -of bedgraph --scaleFactor $scale_factor -bs 5 --normalizeUsing RPGC --effectiveGenomeSize 2864785220 -e 150 -bl ${jobPath}/ENCFF200UUD.bed

## NOT SCALED ONLY NORMALIZED TO RPGC
bamCoverage -b $bamPath/${NAME}.mapped.bam -o $projPath/alignment/blacklistRemoved/${NAME}_unscaled.bedgraph -of bedgraph -bs 5 --normalizeUsing RPGC --effectiveGenomeSize 2864785220 -e 150 -bl ${jobPath}/ENCFF200UUD.bed



