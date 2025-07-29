#!/bin/bash
#SBATCH --job-name=consensus_peaks
#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --output=consensus_%j.out
#SBATCH --error=consensus_%j.err

## Load any required modules
# module load python/3.9
jobPath="/path/to/scripts"

## Move to the peaks directory
cd $PEAKS_PATH

## Create HQ subdirectory if it doesn't exist
mkdir -p HQ

## Run consensus analysis for the specified group
if [ "$GROUP" == "siControl" ]; then
    # Use specific pattern to avoid matching siControl_H3K4me3
    PATTERN="siControl_[0-9]*_peaks.narrowPeak"
else
    # Use standard pattern for other groups
    PATTERN="${GROUP}_*_peaks.narrowPeak"
fi

python3 ${jobPath}/consensus_peaks_analysis.py \
    --input-dir "$PEAKS_PATH" \
    --pattern "$PATTERN" \
    --output "HQ/${GROUP}_HQ.bed" \
    --min-samples 3 \
    --summary

echo "Completed consensus analysis for $GROUP"
echo "Output saved to: $PEAKS_PATH/HQ/${GROUP}_HQ.bed"
