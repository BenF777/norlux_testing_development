#!/bin/bash
CONFIG_FILE=$1
source $CONFIG_FILE

OUT_PATH=$2
BED_FILE=$3
FILENAME=$4

OUT=$OUT_PATH/$(basename $FILENAME)
OUT=${OUT%_aligned.bam}
OUT=${OUT}_platypus
echo $OUT

python $PLATYPUS_BINARY callVariants --bamFiles=$FILENAME --refFile=$REFERENCE --regions=$BED_FILE --output=${OUT}_snv.vcf --filterDuplicates=0 --nCPU=$DNA_PARALLEL_ALIGNMENT --genSNPs 1 --genIndels 0 --logFileName=$OUT.log

bgzip -c ${OUT}_snv.vcf > ${OUT}_snv.vcf.gz

tabix -p vcf ${OUT}_snv.vcf.gz

echo "FILTER Platypus"
#Rscript $SCRIPT_PATH/dna/VariantFilter_platypus_INDEL.R 40 -1 -1 ${OUT}.vcf.gz
#Rscript $SCRIPT_PATH/dna/VariantFilter_platypus_SNP.R 40 0.1 0.1 ${OUT}_snv.vcf.gz
python $SCRIPT_PATH/dna/VariantFilter_platypus.py ${OUT}_snv.vcf $BED_FILE 40 0.1 0.1

#variant annotation
echo "VARIANT ANNOTATION"

#bash $SCRIPT_PATH/dna/anovar_annotate.sh $CONFIG_FILE $(ls -d -1 ${OUT}_snv_filtered_DP40_AF0.1.vcf)

#Rscript $SCRIPT_PATH/dna/annovar_csv2xlsx_platypus.R  $(ls -d -1 ${OUT}_filtered_DP40_AF0.1.hg19_multianno.csv)

echo "$OUT finished"
