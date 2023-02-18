#!/bin/bash

less 16_dplist2.txt | perl -ne 'chomp;@a=split;print "perl /home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin/gvcf_masked_repeat.v2.pl /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/10_reCallVariants/$a[0]_raw_snps_indels.g.vcf.gz --DPmin $a[1] --DPmax $a[2] > /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/20_gvcf_GC/$a[0]_filter.gvcf\n"' > 20_run_gvcf_GC.tmp.sh


