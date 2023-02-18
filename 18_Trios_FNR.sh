#!/bin/bash

VCF=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/15_MendelianCheck_bqsr.GAKTbest/ALLTrios_bqsr_SNP_hardfilterPASS_MaskedRepeat_MendelianConsistent.vcf.gz
PED=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/pedigree/family_trios.ped
output=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/18_FNR_estimate
tmp=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/18_FNR_estimate/tmp
dplist=/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/16_dplist2.txt

perl /home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin/trios_FNR_pipeline.pl $VCF $PED -o $output --tmp $tmp --DPlist $dplist --minAB 0.3 --maxAB 0.7


