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

### G4Catchall analysis
The G4Catchall analysis uses code from:

Doluca, O. (2019). *G4Catchall: A G-quadruplex prediction approach considering atypical features*. Journal of Theoretical Biology, 463, 92–98. https://doi.org/10.1016/j.jtbi.2018.12.007

The original code is available at [[G4Catchall Repository]([insert-link-here](https://github.com/odoluca/G4Catchall)].

We greatly appreciate the authors' contributions to the field and for sharing their work.
We used the following expression with their code to identify the G4s of interest: -–G2L 1..12 --max_imperfect_Gtracts 0 --G4H

Based on the G4Catchall output we look at: 
* G4s per peak
  * Adapt the path in the count_G4s_per_peak.sh script and run the script.
  * This will result in a .txt file with the amount of G4s in column one and the peak name in column 2.
  * Adapt the path name in the Avg_G4s_per_peak.sh script. Then run it. This will result in one file containing an average G4/peak number for each file you included in the analysis. 

* Peaks containing G4s
  * Use the wc -l command on the GPP.txt files resulting from the count_G4s_per_peak.sh script. Every line corresponds to one peak. 

* Average G4 length
  * Adapt the paths in the Avg_G4_length.sh script to get the average length of the detected G4 in G4Catchall.

* G4 coverage
  * Based on all this data you can calculate the G4 coverage per 100bp. To do this use the following formula: G4s/1000bp=  (total G4s)/(amount of peaks*average peak length)*1000

### Pathway analysis
To look at the pathways in which your peaks are involved you can follow the insctructions here: https://www.bioconductor.org/packages/devel/bioc/vignettes/ChIPseeker/inst/doc/ChIPseeker.html

### Assigning strandedness to genome features based on the nearest gene
Fot the INDUCE-seq data analysis we wanted to see what feature coould explain the directional pattern of the breaks surrounding G4 peaks. We thought transcription could be a feature of interest. Since many G4s are present in promotors we decided to look at that first. Promotors do not have a strandedness intrinsically, but you can assign one based on the location (+/- strand) of the nearest gene. You can use the Strand_assignment_based_on_genes_github.Rmd script to do so. Adapt the paths and file names where necessary. 

## G4 composition analysis
Based on the G4Catchall predicted G4s you can analyze the loop composition and length of G runs. 
* This analysis is not without faults: if the first run has 2 Gs and the second run has 3 Gs it is very likely that one of the Gs in the second run is actually in a loop, however, it is not possible to determine which one, therefore the script will not separate a G into a loop and will just report the amount of Gs found in a row.
* Adapt the paths and file extensions in Launch_looplenth_5.0_G4Catchall.sh and looplength_5.0_G4Catchall_Job.sh. Run Launch_looplenth_5.0_G4Catchall.sh, this will call the two other scripts.
* This will output 2 txt files per file you run.
  * The first file with extension _looplength.txt contains all the G4s that have 3 loops, the G4s recognized by quadparser on the opposite strand (meaning containing c’s instead of g’s) will have been inverted, and the table will contain the lengths of each G-run and loop as well as the distribution of the bases in those loops.
  * The second file with extension _looplength_zerollop.txt contains all the G4s that have less than 3 loops, meaning that there are two runs of G’s separated by 0 bases (or containing only G’s in the loops). Here it is impossible to know where the 0 loop is or if there are G-loops, we therefore preferred to exclude them. However, it might be interesting to look at the proportion of zero loop G4s in the total G4s detected by quadparser. Some perturbations could possibly have a preference for these. If you are interested in this: use wc -l again. 

