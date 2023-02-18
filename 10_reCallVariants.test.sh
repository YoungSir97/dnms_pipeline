#!/bin/bash
module load apps/biosoft/bwa/0.7.17-gcc-4.5.8
module load apps/biosoft/samtools/1.12-gcc.4.8.5
module load apps/biosoft/gatk/4.1.9.0

# manual options <<<
pathRAW="/public/home/wanglab2021/1.Project/00.RawData_20210817/filter/output/DNA0001_F07051/" #手动修改
# -----------------------------------------------------------------------------------
FREAD=`ls ${pathRAW}/*__1__*val*.fq.gz | perl -ne "s/.*\///g;print"`
echo "R1: $FREAD"
RREAD=`ls ${pathRAW}/*__2__*val*.fq.gz | perl -ne "s/.*\///g;print"`
echo "R2: $FREAD"

pathREF="/public/home/wanglab2021/1.Project/00.RawData_20210817/assembly/"
REF="/public/home/wanglab2021/1.Project/00.RawData_20210817/assembly/GCF_003957565.2_bTaeGut1.4.pri_genomic.rename.fa"

pathBAM="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/bam/"
pathPED="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/pedigree/"
pathVCF="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/vcf/"
pathTMP="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/tmp/"

STARTTIME=$(date)

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

# ----------------------------------------------------------------------------------
# Create TMP folder and change TMP path
mkdir ${pathTMP}${i}
pathTMP=${pathTMP}${i}

# -----------------------------------------------------------------------------------
# Call variants [GATK]. This will only produce a gVCF which can later be combined with
# all the others for genotype calling.
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" HaplotypeCaller \
    --reference ${REF} \
    --input ${pathBAM}${i}_mapped_fixmate_sorted_bqsr.bam \
    --min-base-quality-score 15 \
    --output-mode EMIT_ALL_ACTIVE_SITES \
    --intervals chr1 --intervals chr1A \
    --intervals chr2 \
    --intervals chr3 \
    --intervals chr4 --intervals chr4A \
    --intervals chr5 \
    --intervals chr6 \
    --intervals chr7 \
    --intervals chr8 \
    --intervals chr9 \
    --intervals chr10 \
    --intervals chr11 \
    --intervals chr12 \
    --intervals chr13 \
    --intervals chr14 \
    --intervals chr15 \
    --intervals chr16 \
    --intervals chr17 \
    --intervals chr18 \
    --intervals chr19 \
    --intervals chr20 \
    --intervals chr21 \
    --intervals chr22 \
    --intervals chr23 \
    --intervals chr24 \
    --intervals chr25 \
    --intervals chr26 \
    --intervals chr27 \
    --intervals chr28 \
    --intervals chrZ \
    --intervals chrW \
    --intervals chr29 \
    --intervals chr30 \
    --intervals chr31 \
    --intervals chr32 \
    --intervals chr33 \
    --intervals chr34 \
    --intervals chr35 \
    --intervals chr36 \
    --intervals chr37 \
    --intervals chrMT \
    --emit-ref-confidence GVCF \
    --output ${pathVCF}${i}_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date) && \
echo "Start: $STARTTIME" && \
echo "End: $ENDTIME" && \
echo "Still waters run deep."

