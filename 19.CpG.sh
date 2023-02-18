#!/bin/bash
#ls /public/home/wanglab2021/1.Project/00.RawData_20210817/process/vcf/10_reCallVariants/*_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz | perl -ne 'chomp;/reCallVariants\/(F\d+)_mapped/ && print "$1\t$_\n"' > gvcf.list

## Outputt information before and after mutation site
perl CpG.pl gvcf.list dnms.info.list > dnms_B1A1.list

less dnms_B1A1.list | perl -ne 'chomp;@a=split;print "$a[0]\t$a[1]\t$a[2]\t$a[5]\t$a[3]->$a[4]\t$a[-3]\n"' > dnms_B1A1.txt
perl CpG2.pl dnms_B1A1.txt  > dnms_CpG.txt

