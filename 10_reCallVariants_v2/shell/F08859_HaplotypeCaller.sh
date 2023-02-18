#!/bin/bash
# manual options
REF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa"
BAM="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/bam/F08859_mapped_fixmate_sorted_bqsr.bam"
outVCF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/10_reCallVariants2/F08859_raw_snps_indels.g.vcf.gz"
pathTMP="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/10_reCallVariants_v2/tmp/F08859"

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
     --min-base-quality-score 15 --output-mode EMIT_ALL_ACTIVE_SITES --emit-ref-confidence BP_RESOLUTION --bam-output ${BAM}_realigned.bam \
    --output ${outVCF} && \
# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."
