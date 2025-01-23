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

### Annotation your peaks 
G4s are often clustered in specific genomic regions like enhancers, promotors and transcription start sites. It is therefore interesting to look at the distribution of your G4s across these regions in your datasets. The roadmap epigenomics project created a database containing files with chromatin mark information and the associated annotations for different human cell lines and tissue types. https://egg2.wustl.edu/roadmap/web_portal/imputed.html#chr_imp
* Once you have your reference file, you can adapt the paths and file name in Annotation_Job.sh and run it. This will loop over your files and intersect them with your reference file keeping the information from both in a resulting file with extension _annotated.bed.
* To easily get an overview of how often the different categories occur, adapt the paths in Annotation_calculation.sh and run it. It will create a Mark_distribution.txt file with in the first column the name of your original file, in the second column the mark name and in the third the occurrence of the mark in your file.

