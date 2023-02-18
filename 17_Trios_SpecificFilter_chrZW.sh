#!/bin/bash

#less /public/home/wanglab2021/1.Project/00.RawData_20210817/process/pedigree/family_trios.ped  | awk '$5==1' > family_trios_male.ped
#less /public/home/wanglab2021/1.Project/00.RawData_20210817/process/pedigree/family_trios.ped  | awk '$5==1' > family_trios_female.ped

VCF=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/15_MendelianCheck_bqsr.GAKTbest/ALLTrios_bqsr_SNP_hardfilterPASS_MaskedRepeat_MendelianViolation.vcf.gz

fPED=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/17_Trios_SpecificFilter_chrZW/family_trios_female.ped
mPED=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/17_Trios_SpecificFilter_chrZW/family_trios_male.ped
foutput=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/17_Trios_SpecificFilter_chrZW/output.female
moutput=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/17_Trios_SpecificFilter_chrZW/output.male

## 过滤2 (1/2*50%~2*50%)
perl trios_SpecificFilter_female_pipeline.pl $VCF $fPED -o $foutput -t ./tmp --DPlist 16_dplist2.txt

perl trios_SpecificFilter_male_pipeline.pl $VCF $mPED -o $moutput -t ./tmp --DPlist 16_dplist2.txt --minAB 0.3 --maxAB 0.7

