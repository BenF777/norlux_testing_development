#!/bin/bash
CONFIG_FILE=$1
source $CONFIG_FILE

FILENAME=$2
AVINPUT=${FILENAME%.vcf}.avinput
CSV_OUT=${FILENAME%.vcf}
$ANNOVAR_HOME/convert2annovar.pl -format vcf4 $FILENAME -outfile $AVINPUT -include -withzyg -includeinfo
$ANNOVAR_HOME/table_annovar.pl $AVINPUT $ANNOVAR_DB -buildver hg19 -out $CSV_OUT -remove -otherinfo -protocol refGene,cytoBand,genomicSuperDups,clinvar_20161128,cosmic68,esp6500siv2_all,popfreq_all_20150413,1000g2015aug_all,1000g2015aug_eur,exac03,avsnp147,dbnsfp30a,snp138,ljb26_all -operation g,r,r,f,f,f,f,f,f,f,f,f,f,f -nastring NA -csvout
