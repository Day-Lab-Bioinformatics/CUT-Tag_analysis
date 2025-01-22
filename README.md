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
