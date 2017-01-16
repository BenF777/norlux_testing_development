#!usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
import sys
from itertools import chain
from os.path import normpath

VCF_FILE = sys.argv[1]
#VCF_FILE = "/home/benflies/Desktop/NGS_DATA/160909-ARKJD_NorLux1/out/var_platypus/T407_platypus_indel.vcf"
BED_FILE = sys.argv[2]
#BED_FILE = "/home/benflies/github/norlux_testing_development/scripts/bed/NPHD_fixed.bed"

depth_threshold = sys.argv[3]
vaf_threshold = sys.argv[4]
sb_threshold = sys.argv[5]

INPUT = re.sub(".vcf", '', VCF_FILE)

OUTPUT_VCF = INPUT+"_filtered.vcf"

info_field = "DP4_freq"

def vcf_converter(vcf_filename):
    lines = []
    variant_counter = 0
    meta = []
    header = []
    variants = []
    with open(vcf_filename, "r") as fin:
        for line in fin.readlines():
            line = line.rstrip('\n')
            line = re.split(r'\t+', line.rstrip('\t'))
            lines.append(line)
    for line in lines:
        if line[0].startswith("##"):
            meta.append(line)
        elif line[0].startswith("#CHROM"):
            header.append(line)
        else:
            variants.append(line)
            variant_counter += 1
    return variants
    return variant_counter

def bed_converter(bed_filename):
    chr_dict = {
        "chr1": [],
        "chr2": [],
        "chr3": [],
        "chr4": [],
        "chr5": [],
        "chr6": [],
        "chr7": [],
        "chr8": [],
        "chr9": [],
        "chr10": [],
        "chr11": [],
        "chr12": [],
        "chr13": [],
        "chr14": [],
        "chr15": [],
        "chr16": [],
        "chr17": [],
        "chr18": [],
        "chr19": [],
        "chr20": [],
        "chr21": [],
        "chr22": [],
        "chrX": [],
        "chrY": [],
        "chrM": [],
    }
    bedlines = []
    bedline_counter = 0
    with open(bed_filename, "r") as bed:
        for bedline in bed.readlines():
            bedline = bedline.rstrip('\n')
            bedline = re.split(r'\t+', bedline.rstrip('\t'))
            bedline_counter +=1
            line_range = range(int(bedline[1]),int(bedline[2]))
            for key, value in chr_dict.items():
                if key == bedline[0]:
                    for i in line_range:
                        chr_dict[key].append(i)
    return chr_dict

def region_filter(vcf, bed):
    counter = 0
    variants = vcf_converter(vcf)
    regions = bed_converter(bed)
    with open(vcf, "r") as inVCF:
        for line in inVCF:
            variant_frequency = 0
            line = line.rstrip('\n')
            line = re.split(r'\t+', line.rstrip('\t'))
            if line[0].startswith("##"):
                print "\t".join(line)
            elif line[0] == '#CHROM':
                print '\t'.join(line)
    for variant in variants:
        for key, value in regions.items():
            if variant[0] == key and int(variant[1]) in value :
                counter += 1
                print '\t'.join(variant)

def VCF_Info_filter(vcf, info_field, threshold):
    with open(vcf, "r") as inVCF:
        for line in inVCF:
            variant_frequency = 0
            flag = 0
            alt_for = 0
            alt_rev = 0
            depth = 0
            SB = 0
            t_1 = 1 - float(threshold)
            line = line.rstrip('\n')
            line = re.split(r'\t+', line.rstrip('\t'))
            if line[0].startswith("##"):
                print "\t".join(line)
            elif line[0] == '#CHROM':
                print '\t'.join(line)
            elif re.search(r'^(\d+|X|Y)|^chr(\d+|X|Y)', line[0]):
                for k,x in enumerate(line[7].split(';')):
                    if info_field == "DP4_freq":
                        if x.split('=')[0] == "NF":
                            if x.split('=')[1].isdigit():
                                alt_for = float(x.split('=')[1])
                        if x.split("=")[0] == "NR":
                            if x.split('=')[1].isdigit():
                                alt_rev = float(x.split("=")[1])
                        if x.split("=")[0] == "TC":
                            if x.split('=')[1].isdigit():
                                depth = float(x.split("=")[1])
                        if type(alt_for) == float and type(alt_rev) == float and type(depth) == float:
                            variant_frequency = float((alt_for + alt_rev) / depth)
                        else:
                            continue
                        if variant_frequency > threshold:
                            flag = 1
                            break
                    elif info_field == "DP4_SB":
                        if x.split('=')[0] == "NF":
                            if x.split('=')[1].isdigit():
                                alt_for = float(x.split('=')[1])
                        if x.split("=")[0] == "NR":
                            if x.split('=')[1].isdigit():
                                alt_rev = float(x.split("=")[1])
                        if type(alt_for) == float and type(alt_rev) == float:
                            SB = float(alt_for / (alt_for + alt_rev))
                        else:
                            continue
                        if SB > threshold and SB < t_1:
                            flag = 1
                            break
                    else:
                        if x.split('=')[0] == info_field:
                            if float(x.split('=')[1]) > threshold:
                                flag = 1
                                break
                if flag == 1 :
                    print '\t'.join(line)
            else:
                continue
                #print '\t'.join(line)

open(INPUT+"_filtered.vcf", "w").writelines([l for l in open(VCF_FILE).readlines()])

sys.stdout = open(INPUT+"_filtered_DP.vcf", "w")
VCF_Info_filter(VCF_FILE,"TC",float(depth_threshold))
sys.stdout.close()
os.remove(INPUT+"_filtered.vcf")

sys.stdout = open(INPUT+"_filtered_DP_FREQ.vcf", "w")
VCF_Info_filter(INPUT+"_filtered_DP.vcf","DP4_freq",float(vaf_threshold))
sys.stdout.close()
os.remove(INPUT+"_filtered_DP.vcf")

sys.stdout = open(INPUT+"_filtered_DP_FREQ_SB.vcf", "w")
VCF_Info_filter(INPUT+"_filtered_DP_FREQ.vcf","DP4_SB",float(sb_threshold))
sys.stdout.close()
os.remove(INPUT+"_filtered_DP_FREQ.vcf")

sys.stdout = open(INPUT+"_filtered_DP_FREQ_SB_intervals.vcf", "w")
region_filter(INPUT+"_filtered_DP_FREQ_SB.vcf", BED_FILE)
sys.stdout.close()
os.remove(INPUT+"_filtered_DP_FREQ_SB.vcf")
