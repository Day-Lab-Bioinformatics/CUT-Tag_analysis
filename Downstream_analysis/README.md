# Downstream analysis
There are many analyses you can perform on called peaks. You will be able to find the ones we routinely perform in this directory. 

## Preparing your peaks for downstream analysis
Generally we try to have at least three replicates per condition for our CUT&Tag data. For the downstream analysis we then continue working with "high quality" peaks, which we define as peaks present in at least 2 or more replicates. 

To generate these high quality peaks, you can use the following command:
```bash
bedtools intersect -wa -u -a most_peaks_replicate.narrowPeak -b other_replicate_1.narrowPeak other_replicate_n.narrowPeak >output.narrowPeak
```

## General downstream analysis
### Generating Fasta files
For a few downstream analyses, you'll need fasta files of your high quality peaks. You can use the Peak_to_fasta.sh script for this. Makes sure to adapt the paths and reference genome file where necessary. 

### Generating size matched shuffled files
Using the Shuffled.sh script, you can generate size matched shuffled files for each narrowPeak file in a given directory. This shuffling takes the chromosome information and the blacklist mentioned in the Data_processing README into account to generate the shuffled files. 

### Getting the average peak length
To calculate the average peak length you can use the Avg_peak_length.sh script. This script will loop over all the narrowPeak files in a given directory, calculate the average peak length for each file and output a text document with on each line a file name and the average peak length for that file. 



