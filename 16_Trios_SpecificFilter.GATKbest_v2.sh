#!/bin/bash

VCF=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/15_MendelianCheck_bqsr.GAKTbest/ALLTrios_bqsr_SNP_hardfilterPASS_MaskedRepeat_MendelianViolation.vcf.gz
PED=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/pedigree/family_trios.ped
output=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/16_SpecificFilter_bqsr.GAKTbest

#perl /public/home/wanglab2021/1.Project/00.RawData_20210817/process/script/bin/trios_SpecificFilter_pipeline.pl $VCF $PED -o $output -t /public/home/wanglab2021/1.Project/00.RawData_20210817/process/vcf/16_SpecificFilter_bqsr.GAKTbest/tmp

## 过滤1 (5%~99%)
# perl /home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin/trios_SpecificFilter_pipeline.pl $VCF $PED -o $output -t /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/16_SpecificFilter_bqsr.GAKTbest/tmp --DPlist 16_dplist.txt

## 过滤2 (1/2*50%~2*50%)
perl /home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin/trios_SpecificFilter_pipeline.pl $VCF $PED -o $output -t /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/16_SpecificFilter_bqsr.GAKTbest/tmp --DPlist 16_dplist2.txt --minAB 0.3 --maxAB 0.7

