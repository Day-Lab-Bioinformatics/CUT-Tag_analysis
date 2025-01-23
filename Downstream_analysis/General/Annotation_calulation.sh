#!/usr/bin/env bash
## Annotation_calculation.sh
## Created by Adrianna Vandeuren on 12/13/2022

## Define the path to your High Quality narrowPeak file
hqPath="/path/to/project/directory/High-Quality"

cd $hqPath

# Array containing names of 25 marks
declare -a StringArray=("1_TssA" "2_PromU" "3_PromD1" "4_PromD2" "5_Tx5" "6_Tx" "7_Tx3" "8_TxWk" "9_TxReg" "10_TxEnh5" "11_TxEnh3" "12_TxEnhW" "13_EnhA1" "14_EnhA2" "15_EnhAF" "16_EnhW1" "17_EnhW2" "18_EnhAc" "19_DNase" "20_ZNF/Rpts" "21_Het" "22_PromP" "23_PromBiv" "24_ReprPC" "25_Quies")


# Loop over files
## Define suffixes

Suffix="_annotated.bed"

for file in *$Suffix
do
    NAME=`ls ${file} | awk -F'_annotated.bed' '{print $1}'`

    for value in ${StringArray[@]}
    do
        MARK=`grep -c $value $file`
        echo -e $NAME '\t' $value '\t' $MARK >> Mark_distribution.txt
    done


done


