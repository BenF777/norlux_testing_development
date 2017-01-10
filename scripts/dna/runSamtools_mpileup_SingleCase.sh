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

#echo $FILENAME #$OUT
REFERENCE=/home/benflies/NGS/references/hg19/ucsc.hg19.fa

samtools mpileup -u -f $REFERENCE $FILENAME | bcftools call -cv -V indels > ${OUT}_snv.bcf
samtools mpileup -u -f $REFERENCE $FILENAME | bcftools call -cv -V snps > ${OUT}_indels.bcf

bcftools view ${OUT}_snv.bcf > ${OUT}_snv.vcf
bcftools view ${OUT}_indels.bcf > ${OUT}_indels.vcf

bgzip -c ${OUT}_snv.vcf > ${OUT}_snv.vcf.gz
bgzip -c ${OUT}_indels.vcf > ${OUT}_indels.vcf.gz

tabix -p vcf ${OUT}_snv.vcf.gz
tabix -p vcf ${OUT}_indels.vcf.gz

#Filter
echo "FILTER $OUT"

Rscript $SCRIPT_PATH/dna/VariantFilter_mpileup_SNP.R 40 0.1 0.1 ${OUT}_snv.vcf.gz
Rscript $SCRIPT_PATH/dna/VariantFilter_mpileup_INDEL.R 40 0.1 0.1 ${OUT}_indels.vcf.gz

#variant annotation
echo "VARIANT ANNOTATION"
bash $SCRIPT_PATH/dna/anovar_annotate.sh $CONFIG_FILE  $(ls -d -1 ${OUT}_snv_filtered_DP40_AF0.1.vcf)
bash $SCRIPT_PATH/dna/anovar_annotate.sh $CONFIG_FILE  $(ls -d -1 ${OUT}_indels_filtered_DP40_AF0.1.vcf)

python $SCRIPT_PATH/dna/csv_reordering_samtools.py ${OUT}_snv_filtered_DP40_AF0.1.hg19_multianno.csv
python $SCRIPT_PATH/dna/csv_reordering_samtools.py ${OUT}_indels_filtered_DP40_AF0.1.hg19_multianno.csv

echo "$OUT finished"
