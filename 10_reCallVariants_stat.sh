#!/bin/bash
for i in /public/home/wanglab2021/1.Project/00.RawData_20210817/process/vcf/*_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz
do
    bcftools stats $i > $i.stat.txt
done


for i in /public/home/wanglab2021/1.Project/00.RawData_20210817/process/vcf/*_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz.stat.txt
do
    filename=`basename $i`
    echo "$filename" | perl -ne '/(\S+)_mapped/ && print ">$1\n"'
    cat $i | perl -ne '/number of SNPs:\s+(\d+)/ && print "\tSNP: $1\n";/number of indels:\s+(\d+)/ && print "\tindels: $1\n"'
done > /public/home/wanglab2021/1.Project/00.RawData_20210817/process/report/10_reCallVariants.stat.txt

