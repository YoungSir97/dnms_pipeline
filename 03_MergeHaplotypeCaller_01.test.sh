#!/bin/bash
#SBATCH --mem=40000
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

# -----------------------------------------------------------------------------------
# Map reads to reference genome [BWA MEM], convert to BAM and clean up read pairing information and flags [samtools]
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

# -----------------------------------------------------------------------------------
# Merge all gvcf files [GATK]
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" GatherVcfs \
   --REFERENCE_SEQUENCE ${REF} \
   --INPUT ${pathVCF}${i}_mapped_fixmate_sorted_raw_snps_indels_chr1_4.g.vcf \
   --INPUT ${pathVCF}${i}_mapped_fixmate_sorted_raw_snps_indels_chr5_end.g.vcf \
   --OUTPUT ${pathVCF}${i}_mapped_fixmate_sorted_raw_snps_indels_GENOME.g.vcf && \
   #--INPUT ${pathVCF}${i}_mapped_fixmate_sorted_bqsr_raw_snps_indels_chr1_5.g.vcf \
   #--INPUT ${pathVCF}${i}_mapped_fixmate_sorted_bqsr_raw_snps_indels_chr6_Un.g.vcf \
   #--OUTPUT ${pathVCF}${i}_mapped_fixmate_sorted_bqsr_raw_snps_indels_GENOME.g.vcf

# -----------------------------------------------------------------------------------
rm ${pathVCF}${i}_mapped_fixmate_sorted_raw_snps_indels_chr1_4.g.vcf ${pathVCF}${i}_mapped_fixmate_sorted_raw_snps_indels_chr5_end.g.vcf && \
echo "Still waters run deep."

