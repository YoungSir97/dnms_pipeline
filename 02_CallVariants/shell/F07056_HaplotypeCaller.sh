#!/bin/bash
module load apps/biosoft/bwa/0.7.17-gcc-4.5.8
module load apps/biosoft/samtools/1.12-gcc.4.8.5
module load apps/biosoft/gatk/4.1.9.0

# -----------------------------------------------------------------------------------
# manual options
REF="/public/home/wanglab2021/1.Project/rawdata_20220911/refgenome_3.2.4/Zebrafinch.rename.fa"
BAM="/public/home/wanglab2021/1.Project/rawdata_20220911/bam/F07056_mapped_fixmate_sorted.bam"
outVCF="/public/home/wanglab2021/1.Project/rawdata_20220911/vcf/F07056_raw_snps_indels.g.vcf.gz"
pathTMP="/public/home/wanglab2021/1.Project/rawdata_20220911/process/script/02_CallVariants/tmp/F07056"

# -----------------------------------------------------------------------------------
STARTTIME=$(date +%s)
# Create folder and change TMP path
[ -d $pathTMP ] || mkdir -p $pathTMP
# -----------------------------------------------------------------------------------
# Call variants [GATK]. This will only produce a gVCF which can later be combined with
# all the others for genotype calling.
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" HaplotypeCaller \
    --reference ${REF} \
    --input ${BAM} \
    --emit-ref-confidence GVCF \
    --output ${outVCF} && \
# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."
