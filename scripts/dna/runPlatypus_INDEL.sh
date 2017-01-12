#!/bin/bash
CONFIG_FILE=$1
source $CONFIG_FILE

OUT_PATH=$2
BED_FILE=$3
BAM_FILE=$4

echo $OUT_PATH
echo $COMPLETE_BED_FILE
echo $BAM_FILE

OUT=$OUT_PATH/$(basename $BAM_FILE)
OUT=${OUT%_MERGED.bam}
OUT=${OUT}_PLATYPUS

python $PLATYPUS_BINARY callVariants --bamFiles=$BAM_FILE --refFile=$REFERENCE --regions=$BED_FILE --output=${OUT}_indel.vcf --filterDuplicates=0 --nCPU=$DNA_PARALLEL_ALIGNMENT --genSNPs 0 --genIndels 1 --logFileName=$OUT.log

bgzip -c ${OUT}_indel.vcf > ${OUT}_indel.vcf.gz

tabix -p vcf ${OUT}_indel.vcf.gz

echo "FILTER Platypus"
#Rscript $SCRIPT_PATH/dna/VariantFilter_platypus_INDEL.R 40 -1 -1 ${OUT}.vcf.gz

python $SCRIPT_PATH/dna/variant_filterer.py ${OUT}_indel.vcf DP=40 DP4_freq=0.1 DP4_SB=0.1

#variant annotation
echo "VARIANT ANNOTATION"

#bash $SCRIPT_PATH/dna/anovar_annotate.sh $CONFIG_FILE $(ls -d -1 ${OUT}_indel_filtered_DP40_AF0.1.vcf)

#Rscript $SCRIPT_PATH/dna/annovar_csv2xlsx_platypus.R  $(ls -d -1 ${OUT}_filtered_DP40_AF0.1.hg19_multianno.csv)

echo "$OUT finished"
