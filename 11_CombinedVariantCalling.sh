#!/bin/bash
#SBATCH --mem=50000
pathTMP="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/tmp/"
REF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa"

STARTTIME=$(date +%s) && \
# -----------------------------------------------------------------------------------
# Genotype all samples combined
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" GenotypeGVCFs \
   --reference $REF \
   -V gendb:///home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/10_reCallVariants/AllTrioGenome2.db \
   --output /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/ALLTrios_bqsr_snps_indels_GENOME.vcf.gz && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."

