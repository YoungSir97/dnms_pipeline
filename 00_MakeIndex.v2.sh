#!/bin/bash
#SBATCH --time=5-00:00:00
#SBATCH --mem=1G
module load apps/biosoft/bwa/0.7.17-gcc-4.5.8
module load apps/biosoft/samtools/1.12-gcc.4.8.5
module load apps/biosoft/gatk/4.1.9.0

### This step is to make the index for reference genome
# -----------------------------------------------------------------------------------
## set parameters
REF="/public/home/wanglab2021/1.Project/rawdata_20220911/refgenome_3.2.4/Zebrafinch.rename.fa"

STARTTIME=$(date +%s)
# -----------------------------------------------------------------------------------
## Prepare reference genome sequence (TaeGut1, WUSTL 3.2.4 [2008]). Needs to be done only once [BWA, Picard, Samtools]
# Using new refergece genome varion (bTaeGut1.4.pri [2021], GCF_003957565.2)
# create index database
bwa index -a bwtsw ${REF} && \

# create dictonary for GATK
gatk CreateSequenceDictionary --REFERENCE ${REF} && \

# create index for GATK
samtools faidx ${REF} && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."

