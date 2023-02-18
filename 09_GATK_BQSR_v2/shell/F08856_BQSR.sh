#!/bin/bash

# -----------------------------------------------------------------------------------
# manual options
REF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa"
BAM="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/bam/bam_raw/F08856_mapped_fixmate_sorted.bam"
outBAM="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/bam_bqsr/F08856_mapped_fixmate_sorted_bqsr.bam"
KNOWNSITES="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/08_HardFilter/TRUESITES.vcf.gz"
pathTMP="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/09_GATK_BQSR_v2/tmp/F08856"

# -----------------------------------------------------------------------------------
STARTTIME=$(date +%s)
# Create folder and change TMP path
[ -d $pathTMP ] || mkdir -p $pathTMP
# -----------------------------------------------------------------------------------
# Base quality recalibration. We do this last, because we want all the data to be as clean as possible when we get here [GATK]
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" BaseRecalibrator \
    --reference ${REF} \
    --input ${BAM} \
    --known-sites ${KNOWNSITES} \
    --output ${BAM}_recal_data.table && \

gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" ApplyBQSR \
    --reference ${REF} \
    --input ${BAM} \
    --bqsr-recal-file ${BAM}_recal_data.table \
    --create-output-bam-index true \
    --output ${outBAM} && \
# -----------------------------------------------------------------------------------
#Check BAM/mapping-quality [BamQC, BAMStats]
qualimap bamqc -bam ${outBAM} --java-mem-size=32G -outdir ${outBAM}_bamqc && \
# -----------------------------------------------------------------------------------
# Remove all intermediate files
#\rm ${BAM} ${BAM}.* && \
\rm -r ${pathTMP} && \
# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."
