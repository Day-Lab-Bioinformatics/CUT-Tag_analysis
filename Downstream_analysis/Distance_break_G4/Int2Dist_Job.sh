#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=G4_inter
#SBATCH --time=00:30:00
#SBATCH --mem=10G
#SBATCH --partition=short


## Int2Dist_Job.sh
## Script created by Annika Salpukas on 9/25/24
## This script will be called by Launch_Int2Dist.sh, you don't need to run it separately.

temp=$(mktemp)

awk 'BEGIN {OFS="\t"} {print $7,$8,$9,$10,$11,$12,$13,$14,$15,$1,$2+100,$3-100,$4,$5,$6}' "$INTERSECTS" > "$temp"

python ${JOBPATH}/int2dist.py $temp $OUTFILE

rm "$temp"