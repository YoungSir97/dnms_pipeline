#!/bin/bash
#SBATCH --mem=50000
pathVCF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/02_CallVariants/"
pathTMP="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/tmp"
REF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa"

STARTTIME=$(date +%s) && \
# -----------------------------------------------------------------------------------
# Genotype all samples combined
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" GenotypeGVCFs \
   --reference $REF \
   -V gendb://${pathVCF}AllTrioGenome.db \
   --output ${pathVCF}ALLTrios_mapped_fixmate_sorted_raw_snps_indels_GENOME.vcf && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."

