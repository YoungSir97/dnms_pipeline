#!/bin/bash
module load apps/biosoft/bwa/0.7.17-gcc-4.5.8
module load apps/biosoft/samtools/1.12-gcc.4.8.5
module load apps/biosoft/gatk/4.1.9.0

pathREF="/public/home/wanglab2021/1.Project/00.RawData_20210817/assembly/"
REF="/public/home/wanglab2021/1.Project/00.RawData_20210817/assembly/GCF_003957565.2_bTaeGut1.4.pri_genomic.rename.fa"

pathBAM="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/bam/"
pathPED="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/pedigree/"
pathVCF="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/vcf/"
pathTMP="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/tmp/"

STARTTIME=$(date +%s)

# -----------------------------------------------------------------------------------
# Create a GenomicsDB that contains all variants [GATK], without sample F07074.
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" GenomicsDBImport \
   --variant ${pathVCF}F07051_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07052_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07053_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07054_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07055_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07056_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07059_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07060_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07062_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07063_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07064_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07065_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07066_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07068_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07069_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F07070_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F08856_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F08857_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F08858_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --variant ${pathVCF}F08859_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf.gz \
   --genomicsdb-workspace-path ${pathVCF}AllTrioGenome.db \
   --intervals chr1 \
   --intervals chr1A \
   --intervals chr2 \
   --intervals chr3 \
   --intervals chr4 \
   --intervals chr4A \
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
   --intervals chrMT && \

ENDTIME=$(date +%s) && \
echo "Finish: Create GenomicsDB. e:$ENDTIME" && \

# Genotype all samples combined
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" GenotypeGVCFs \
    --reference $REF \
    -V gendb://${pathVCF}AllTrioGenome.db \
    --output ${pathVCF}ALLTrios_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.vcf.gz && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
echo "s:$STARTTIME \t e:$TIMESPEND" && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."

