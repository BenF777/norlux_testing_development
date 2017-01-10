    #!usr/bin/env python
# -*- coding: utf-8 -*-

import csv
import re
import sys

#INPUT_CSV = sys.argv[1]
#INPUT = re.sub(".csv", '', INPUT_CSV)
#OUTPUT_CSV = INPUT+"_reordered.csv"1

INPUT_CSV = "186PDX_aligned.bam_MPILEUP_filtered_DP40_AF0.1.hg19_multianno.csv"
OUTPUT_VAF_DP = "test_with_VAF_DP.csv"
REORDERED_OUTPUT_CSV = "test_final.csv"

def csv_to_dict(file_name):
    rows = []
    with open(file_name, "rt") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:

            row["Otherinfo"] = re.split(r'\t+', row["Otherinfo"].rstrip('\t'))
            l1 = [elem.strip().split(';') for elem in row["Otherinfo"]]

            depth = [re.sub("DP=", '', s) for s in l1[10] if "DP=" in s][0]
            row["Read_Depth"] = str(depth)

            dp4 = [re.sub("DP4=", '', s) for s in l1[10] if "DP4=" in s]
            dp4[0] = re.split(r',+', dp4[0].rstrip(','))

            ref_for = float(dp4[0][0])
            ref_rev = float(dp4[0][1])
            alt_for = float(dp4[0][2])
            alt_rev = float(dp4[0][3])

            if ref_for != 0 and ref_rev != 0:
                af = (alt_for + alt_rev) / (ref_for + ref_rev + alt_for + alt_rev)
            else:
                af = 1

            row["Variant_Allele_Frequency"] = af

            row["cosmic68"] = re.sub(",","|",row["cosmic68"])
            row["cosmic68"] = re.sub(";","|",row["cosmic68"])

            rows.append(row)

    return rows

dictionary = csv_to_dict(INPUT_CSV)

with open(OUTPUT_VAF_DP,"a") as outfile:
    field_names = ["Chr","cytoBand","Start","End","Ref","Alt","snp138","Gene.refGene","Func.refGene","ExonicFunc.refGene","AAChange.refGene","Variant_Allele_Frequency","Read_Depth","CLINSIG","CLNDBN","cosmic68","CLNACC","CLNDSDB","CLNDSDBID","esp6500siv2_all","PopFreqMax","1000G_ALL","1000G_AFR","1000G_AMR","1000G_EAS","1000G_EUR","1000G_SAS","ExAC_ALL","ExAC_AFR","ExAC_AMR","ExAC_EAS","ExAC_FIN","ExAC_NFE","ExAC_OTH","ExAC_SAS","ESP6500siv2_ALL","ESP6500siv2_AA","ESP6500siv2_EA","CG46","avsnp147","SIFT_score","SIFT_pred","Polyphen2_HDIV_score","Polyphen2_HDIV_pred","Polyphen2_HVAR_score","Polyphen2_HVAR_pred","LRT_score","LRT_pred","MutationTaster_score","MutationTaster_pred","MutationAssessor_score","MutationAssessor_pred","FATHMM_score","FATHMM_pred","PROVEAN_score","PROVEAN_pred","VEST3_score","CADD_raw","CADD_phred","DANN_score","fathmm-MKL_coding_score","fathmm-MKL_coding_pred","MetaSVM_score","MetaSVM_pred","MetaLR_score","MetaLR_pred","integrated_fitCons_score","integrated_confidence_value","GERP++_RS","phyloP7way_vertebrate","phyloP20way_mammalian","phastCons7way_vertebrate","phastCons20way_mammalian","SiPhy_29way_logOdds","SIFT_score","SIFT_pred","Polyphen2_HDIV_score","Polyphen2_HDIV_pred","Polyphen2_HVAR_score","Polyphen2_HVAR_pred","LRT_score","LRT_pred","MutationTaster_score","MutationTaster_pred","MutationAssessor_score","MutationAssessor_pred","FATHMM_score","FATHMM_pred","RadialSVM_score","RadialSVM_pred","LR_score","LR_pred","VEST3_score","CADD_raw","CADD_phred","GERP++_RS","phyloP46way_placental","phyloP100way_vertebrate","SiPhy_29way_logOdds","Otherinfo"]
    writer = csv.DictWriter(outfile, fieldnames=field_names, extrasaction="ignore")
    writer.writeheader()
    for line in dictionary:
        for col in line:
            col = str(col)
        writer.writerow(line)
