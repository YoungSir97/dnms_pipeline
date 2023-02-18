#!/bin/bash
module load apps/biosoft/gatk/4.1.9.0

# manual options
REF="/public/home/wanglab2021/1.Project/00.RawData_20210817/assembly/GCF_003957565.2_bTaeGut1.4.pri_genomic.rename.fa"
BAM="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/bam/test.bam"
KNOWNSITES=""
pathTMP="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/tmp/"
outBAM=""

STARTTIME=$(date)
# -----------------------------------------------------------------------------------
# Base quality recalibration. We do this last, because we want all the data to be as clean as possible when we get here [GATK]
# input VCF must be indexed
echo -n "Start: IndexFeatureFile and BaseRecalibrator and ApplyBQSR at " && date && \
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" BaseRecalibrator \
    --input $BAM \
    --reference $REF \
    --known-sites $KNOWNSITES \
    --output ${BAM}_recal_data.table && \

gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" ApplyBQSR \
    --reference $REF \
    --input $BAM \
    --bqsr-recal-file ${BAM}_recal_data.table \
    --create-output-bam-index true \
    --output $outBAM && \

# -----------------------------------------------------------------------------------
# Check BAM/mapping-quality [BamQC, BAMStats]
qualimap bamqc -bam $outBAM --java-mem-size=64G -outdir ${outBAM}_bamqc && \

# -----------------------------------------------------------------------------------
# Remove all intermediate files
rm ${pathBAM}/${i}_mapped_fixmate_sorted.bam ${pathBAM}/${i}_mapped_fixmate_sorted.bam.*&& \
rm -r ${pathTMP} && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date) && \
echo "Start: $STARTTIME" && \
echo "End: $ENDTIME" && \
echo "Still waters run deep."

