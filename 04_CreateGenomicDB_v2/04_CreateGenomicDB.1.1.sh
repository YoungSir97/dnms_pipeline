#!/bin/bash
# manual options <<<
REF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa"
pathVCF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/"
pathTMP="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/04_CreateGenomicDB/tmp1.2/"
LIST="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/04_CreateGenomicDB/interval1.2.list"

STARTTIME=$(date +%s)
# -----------------------------------------------------------------------------------
# Create a GenomicsDB that contains all variants [GATK]
gatk --java-options "-Djava.io.tmpdir=${pathTMP}" GenomicsDBImport \
   -L $LIST \
   --variant ${pathVCF}F07051_raw_snps_indels.g.vcf \
   --variant ${pathVCF}F07052_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07053_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07054_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07055_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07056_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07059_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07060_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07062_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07063_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07064_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07065_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07066_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07068_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07069_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07070_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F08856_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F08857_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F08858_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F08859_raw_snps_indels.g.vcf.gz \
   --genomicsdb-workspace-path ${pathVCF}AllTrioGenome.db11 && \

echo "finish CreateGenomicDB" && \

gatk --java-options "-Djava.io.tmpdir=${pathTMP}" GenotypeGVCFs \
   --reference $REF \
   -V gendb://${pathVCF}AllTrioGenome.db11 \
   --output ${pathVCF}ALLTrios_raw_snps_indels11.vcf && \


# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."
