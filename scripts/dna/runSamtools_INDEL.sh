#!/bin/bash
CONFIG_FILE=$1
source $CONFIG_FILE

OUT_PATH=$2
BED_FILE=$3
FILENAME=$4

echo "run samtools"
OUT=$OUT_PATH/$(basename $FILENAME)
OUT=${OUT%_aligned.bam}
OUT=${OUT}_samtools
echo $OUT

samtools mpileup -u -f $REFERENCE $FILENAME | bcftools call -cv -V snps > ${OUT}_indel.bcf

bcftools view ${OUT}_indel.bcf > ${OUT}_indel.vcf

bgzip -c ${OUT}_indel.vcf > ${OUT}_indel.vcf.gz

tabix -p vcf ${OUT}_indel.vcf.gz

#Filter
echo "FILTER $OUT"

python $SCRIPT_PATH/dna/VariantFilter_samtools.py ${OUT}_indel.vcf $BED_FILE DP=40 DP4_freq=0.1 DP4_SB=0.1

#Variant Annotation
echo "VARIANT ANNOTATION"
bash $SCRIPT_PATH/dna/anovar_annotate.sh $CONFIG_FILE  $(ls -d -1 ${OUT}_indel_filtered_DP_FREQ_SB_intervals.vcf)

python $SCRIPT_PATH/dna/csv_reordering_samtools.py ${OUT}_indel_filtered_DP_FREQ_SB_intervals.hg19_multianno.csv

echo "$OUT finished"
