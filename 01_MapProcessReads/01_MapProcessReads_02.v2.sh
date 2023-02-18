#!/bin/bash
#SBATCH --time=5-00:00:00
#SBATCH --mem=160000
module load apps/biosoft/bwa/0.7.17-gcc-4.5.8
module load apps/biosoft/samtools/1.12-gcc.4.8.5
module load apps/biosoft/gatk/4.1.9.0

### script description: Map reads to reference genome [BWA MEM]; Mark duplicates and sort BAM by position [GATK4]
# -----------------------------------------------------------------------------------
# manual options
pathRAW="/public/home/wanglab2021/1.Project/00.RawData_20210817/filter/output/DNA0002_F07052/" #手动修改
REF="/public/home/wanglab2021/1.Project/rawdata_20220911/refgenome_3.2.4/Zebrafinch.rename.fa"
pathBAM="/public/home/wanglab2021/1.Project/rawdata_20220911/bam"
pathTMP="/public/home/wanglab2021/1.Project/rawdata_20220911/tmp"

# -----------------------------------------------------------------------------------
FREAD=`ls ${pathRAW}/*__1__*val*.fq.gz | perl -ne "s/.*\///g;print"`
echo "R1: $FREAD"
RREAD=`ls ${pathRAW}/*__2__*val*.fq.gz | perl -ne "s/.*\///g;print"`
echo "R2: $RREAD"

STARTTIME=$(date +%s)
# -----------------------------------------------------------------------------------
# create read group information
i=`echo ${FREAD} | cut -f 41 -d "_"`
ID=`echo ${FREAD} | cut -f 29 -d "_" | cut -c 2-`.`echo ${FREAD} | cut -f 37 -d "_" | rev | cut -c 1`.`echo ${FREAD} | cut -f 31 -d "_"`
LB=`echo ${FREAD} | cut -f 19,41 -d "_"`
PL=`echo ${FREAD^^} | cut -f 19 -d "_"`
SM=`echo ${FREAD} | cut -f 41 -d "_"`
PU=${ID}
CN="Kiel"
DS="Inversion"
echo "i:$i ID:$ID LB:$LB PL:$PL SM:$SM PU:$PU"
pathTMP="$pathTMP/$i"
mkdir -p $pathTMP

# ---------------------------------------------------------------------------------
# Map reads to reference genome [BWA MEM], convert to BAM and clean up read pairing information and flags [samtools]
echo -n "Start: bwa mem at " && date
bwa mem -t 16 ${REF} \
   -R "@RG\tID:${ID}\tLB:${LB}\tPL:${PL}\tSM:${SM}\tPU:${PU}\tCN:${CN}\tDS:${DS}" \
   ${pathRAW}/${FREAD} \
   ${pathRAW}/${RREAD} \
   | samtools view - -F 12 -b -@ 16 \
   | samtools fixmate -O bam -@ 16 - ${pathBAM}/${i}_mapped_fixmate.bam && \

# ----------------------------------------------------------------------------------
# Mark duplicates and sort BAM by position [GATK4]
echo -n "Start: Mark duplicates at " && date && \
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" MarkDuplicatesSpark \
   --input ${pathBAM}/${i}_mapped_fixmate.bam \
   --output ${pathBAM}/${i}_mapped_fixmate_sorted.bam \
   --create-output-bam-index true \
   --read-validation-stringency STRICT && \

# count duplicated reads
echo -n "Start: count duplicated reads at " && date && \
samtools view -@ 16 -f 1024 -c ${pathBAM}/${i}_mapped_fixmate_sorted.bam &&\

# ----------------------------------------------------------------------------------
# Validate the BAM
echo -n "Start: Validate BAM at " && date && \
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" ValidateSamFile \
   --INPUT ${pathBAM}/${i}_mapped_fixmate_sorted.bam && \

# -----------------------------------------------------------------------------------
# Base quality recalibration. We do this last, because we want all the data to be as clean as possible when we get here [GATK]
# input VCF must be indexed
#echo "Start: IndexFeatureFile and BaseRecalibrator and ApplyBQSR at " && date && \
#gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" IndexFeatureFile \
#   --feature-file ${pathVCF}/TRUESITES.vcf &&\
#
#gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" BaseRecalibrator \
#   --input ${pathBAM}/${i}_mapped_fixmate_sorted.bam \
#   --reference ${REF} \
#   --known-sites ${pathVCF}/TRUESITES.vcf \
#   --output ${pathBAM}/${i}_recal_data.table && \
#
#gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" ApplyBQSR \
#   --reference ${REF} \
#   --input ${pathBAM}/${i}_mapped_fixmate_sorted.bam \
#   --bqsr-recal-file ${pathBAM}/${i}_recal_data.table \
#   --create-output-bam-index true \
#   --output ${pathBAM}/${i}_mapped_fixmate_sorted_bqsr.bam && \
#
# -----------------------------------------------------------------------------------
# Check BAM/mapping-quality [BamQC, BAMStats]
###/data/home/wolfproj/wolfproj-01/Software/BamQC/bin/bamqc ${pathBAM}${i}_mapped_fixmate_sorted_bqsr.bam

###java -Xmx150g -jar /data/home/wolfproj/wolfproj-01/Software/BAMStats-1.25/BAMStats-1.25.jar \
###    --mapped --qualities --view html \
###    --infile ${pathBAM}${i}_mapped_fixmate_sorted_bqsr.bam \
###    --outfile ${pathBAM}${i}_mapped_fixmate_sorted_bqsr_BAMStats.html

# -----------------------------------------------------------------------------------
# Remove all intermediate files
rm ${pathBAM}/${i}_mapped_fixmate.bam* && \
#rm ${pathBAM}/${i}_mapped_fixmate_sorted.bam* && \
rm -r ${pathTMP} && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) &&\
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."
