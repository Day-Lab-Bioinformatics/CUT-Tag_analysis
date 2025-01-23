# CUT-Tag_analysis

This README provides a step-by-step guide for performing CUT&Tag analysis.

## Prerequisites

You will need a few environments (cut_n_tag.yml , Java.yml and MACS2.yml) to run the analysis: 

Install the environments by using the following command:
```bash
conda create --name <env> --file <this file>
```
For the cut_N_tag environment use:
```bash
conda env create -f cut_n_tag.yml
```

## Genome build

UCSC is a great resource to find genome sequence files: https://hgdownload.soe.ucsc.edu/downloads.html
Identify the genome you need and adapt the Genome_Assembly.sh script to match the paths and file names you need.

## Pre-run quality control

Before starting the data processing, assess if the quality of the data is suitable by using FASTQC. 
*	Adapt the paths and file extensions in the Launch_FASTQC.sh and FASTQC_Job.sh scripts
*	Run Launch_FASTQC.sh to parallelize the FASTQC_Job.sh script on all your files to get quality control data from the sequencing results.

## Align to the genomes of interest
*	Adapt the paths in Launch_Alignment.sh and Alignment_Job.sh as needed. 
*	Run Launch_Alignment.sh, this will loop over all the files in the folder containing your sequencing resutls and launch an sbatch background job using Alignment_Job.sh for each file in parallel.

## Remove duplicates
Remove the duplicates in your files. This is not always recommended for CUT&Tag. If you are looking at chromatin modifications Tn5 will cut in open chromatin and thus will very likely cut at similar places in all cells. In that case it is likely that your duplicates are not due to the library prep PCR, but due to true Tn5 detection. 
* Adapt the paths and suffixes as needed in Launch_Duplicate_Removal and Duplicate_Removal_Job.sh.
* Run the Launch_Duplicate_Removal.sh script which will call the duplicate removal script for each file.  

## File conversion and peak calling
From here on the scripts differ depending on which method you want to use for peak calling. Our preferred method is MACS2, however if your spike-in proportion is very variable and you woul like to scale to the spike-in, then SEACR is advised. 

You will also remove blacklist regions. These are regions that have annomalous, unstructured or high signal in next generation sequencing. I use ENCFF200UUD.bed as blacklist for the hg19 human genome. You can find blacklist regions on the Boyle lab github page: https://github.com/Boyle-Lab/Blacklist/tree/master/lists they are based on the following article: https://www.nature.com/articles/s41598-019-45839-z#data-availability

### MACS2 file conversion and peak calling
Convert the files from sam to bam format using samtools.
*	Adapt the filenames and paths in Launch_Format_Conversion.sh and Format_Conversion_Job.sh.
*	Run the Launch_Format_Conversion.sh script which will call the format conversion script for each file in parallel.

*	Adapt the paths and file names in Launch_Peak_Calling.sh and in Peak_Calling_Job.sh to match your data.
* Based on the organism your samples originated from you need to adapt what comes after -g in the MACS2 peakcalling line: hs = homo sapiens, mm = mus musculus, ce = C. elegans, dm = drosophila melanogaster. 
*	Run Launch_Peak_Calling.sh which will launch Peak_Calling_Job for each file to call peaks and create bam coverage files.
  
To count the amount of called peaks easily run the following command:
```bash
wc -l *.narrowPeak
```

### SEACR file conversion and peak calling
Convert the files from sam to bam format using samtools. 
Using the seqDepth calculated during the alignment to the Drosophila genome, the script will find the scaling factor and then use it as input for bamCoverage to change the format from bam to bedgraph. It is advised to verify the seqDepth value and adapt the arbitrary value in the scaling factor calculation base on the range of seqDepth values (we don't want a scaling factor that is too big). 
*	Adapt the filenames and paths in Launch_Format_Conversion_Scale.sh and Format_Conversion_Job_Scaled.sh.
*	Run the Launch_Format_Conversion_Scaled.sh script which will call the format conversion script for each file in parallel.

Copy the SEACR_calling.sh script to the directory containing the bedgraph files you want to call peaks from. Then run this script. 
* NOTE: I did not manage to get SEACR to work while parallelizing the process for all files, however, it only takes a few minutes to run, so parallelization is not necessary. 
* Adapt the necessary filenames and paths

  


