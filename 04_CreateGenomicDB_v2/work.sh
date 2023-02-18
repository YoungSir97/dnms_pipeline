#!/bin/bash
#less /home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa.interval.list  | head -1800  > interval.list1
#less /home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa.interval.list  |head -10000 |tail -n +1801 > interval.list2
#less /home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa.interval.list | head -20000 | tail -10000 > interval.list3
#less /home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa.interval.list | tail -n +20001 > interval.list4

#ls /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/10_reCallVariants/F*.vcf.gz | perl -ne '/(F\d+)_raw_snps_indels.g.vcf.gz/ && print "$1\n"' > samplelistname.txt
#bcftools view -S samplelistname.txt  -Ov > samplelist_1000Genomes.vcf
#bgzip /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels122.vcf
#tabix -p vcf /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels122.vcf.gz
#bgzip /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_tmp/ALLTrios_raw_snps_indels121.vcf
#tabix -p vcf /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_tmp/ALLTrios_raw_snps_indels121.vcf.gz

#bcftools merge /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_tmp/ALLTrios_raw_snps_indels121.vcf.gz \
#    /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels122.vcf.gz \
#    --output-type z -o /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels.chr3.vcf.gz

#bgzip /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels1.vcf
#tabix -p vcf /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels1.vcf.gz
#bgzip /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels2.vcf
#tabix -p vcf /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels2.vcf.gz
#bgzip /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels3.vcf
#tabix -p vcf /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels3.vcf.gz
#bgzip /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels4.vcf
#tabix -p vcf  /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels4.vcf.gz
bgzip /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels11.vcf
tabix -p vcf /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels11.vcf.gz

bcftools concat \
    /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels1.vcf.gz \
    /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels.chr3.vcf.gz \
    /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels11.vcf.gz \
    /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels2.vcf.gz \
    /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels3.vcf.gz \
    /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps_indels4.vcf.gz \
    --output-type z -o /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/ALLTrios_raw_snps.vcf.gz

