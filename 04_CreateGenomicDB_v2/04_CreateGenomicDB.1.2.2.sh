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
   -L chr3 \
   --variant ${pathVCF}F07069_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F07070_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F08856_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F08857_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F08858_raw_snps_indels.g.vcf.gz \
   --variant ${pathVCF}F08859_raw_snps_indels.g.vcf.gz \
   --genomicsdb-workspace-path ${pathVCF}AllTrioGenome.db122 && \

echo "finish CreateGenomicDB" && \

gatk --java-options "-Djava.io.tmpdir=${pathTMP}" GenotypeGVCFs \
   --reference $REF \
   -V gendb://${pathVCF}AllTrioGenome.db122 \
   --output ${pathVCF}ALLTrios_raw_snps_indels122.vcf && \


# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."
