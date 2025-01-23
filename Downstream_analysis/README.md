# Downstream analysis
There are many analyses you can perform on called peaks. You will be able to find the ones we routinely perform in this directory. 

## Preparing your peaks for downstream analysis
Generally we try to have at least three replicates per condition for our CUT&Tag data. For the downstream analysis we then continue working with "high quality" peaks, which we define as peaks present in at least 2 or more replicates. 

To generate these high quality peaks, you can use the following command:
```bash
bedtools intersect -wa -u -a most_peaks_replicate.narrowPeak -b other_replicate_1.narrowPeak other_replicate_n.narrowPeak >output.narrowPeak
```

