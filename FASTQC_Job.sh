#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=FASTQC
#SBATCH --time=4:00:00
#SBATCH --mem=10G
#SBATCH --partition=short

## FASTQC_Job.sh 
## Created by Adrianna Vandeuren 08/02/2023

projPath="/path/to/project/directory"


## Depending on how you load picard and your server environment, the picardCMD can be different. Adjust accordingly.
## picardCMD="java -jar picard.jar"
## We have picard in the conda environment called cut_N_tag
module load anaconda3
conda init
source activate cut_N_tag


fastqc -o ${projPath}/fastqFileQC/${NAME} -f fastq ${R1}
fastqc -o ${projPath}/fastqFileQC/${NAME} -f fastq ${R2}




