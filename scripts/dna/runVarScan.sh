#!/bin/bash
CONFIG_FILE=$1
source $CONFIG_FILE

OUT_PATH=$2
BED_FILE=$3
FILENAME=$4

echo "run samtools"
OUT=$OUT_PATH/$(basename $FILENAME)
OUT=${OUT%_aligned.bam}
OUT=${OUT}_varscan
echo $OUT

COV=40
FREQ=0.1

#echo $FILENAME #$OUT
REFERENCE=/home/benflies/NGS/references/hg19/ucsc.hg19.fa

samtools mpileup -f $REFERENCE -l $BED_FILE $FILENAME | java -jar $VARSCAN_HOME/VarScan.v2.4.3.jar mpileup2snp --min-coverage $COV --min-var-freq $FREQ --output-vcf > ${OUT}.vcf

bgzip -c ${OUT}.vcf > ${OUT}.vcf.gz

tabix -p vcf ${OUT}.vcf.gz

#variant annotation
echo "VARIANT ANNOTATION"
bash $SCRIPT_PATH/dna/anovar_annotate.sh $CONFIG_FILE  $(ls -d -1 ${OUT}.vcf)

Rscript $SCRIPT_PATH/dna/annovar_csv2xlsx_mpileup.R  $(ls -d -1 ${OUT}.hg19_multianno.csv)

echo "$OUT finished"
