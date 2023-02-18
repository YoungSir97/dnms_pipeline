#!/bin/bash -e
module load apps/biosoft/bwa/0.7.17-gcc-4.5.8
module load apps/biosoft/samtools/1.12-gcc.4.8.5
module load apps/biosoft/gatk/4.1.9.0

### Set path before run shell ###
# -----------------------------------------------------------------------------------
# reference genome
REF="/public/home/wanglab2021/1.Project/rawdata_20220911/refgenome_3.2.4/Zebrafinch.rename.fa"
# input variants file
inputVCF="/public/home/wanglab2021/1.Project/rawdata_20220911/vcf/ALLTrios_mapped_fixmate_sorted_raw_snps_indels_GENOME.vcf"
# output file path and prefix
outputPath="/public/home/wanglab2021/1.Project/rawdata_20220911/vcf/06_SelectVariants"
outputName="ALLTrios_06_raw"  # If not set, the input file name will be used.
# samples number
sampleNumber=20
# report output path
pathREPORT="/public/home/wanglab2021/1.Project/rawdata_20220911/process/report"
# other path
pathSCRIPT="/public/home/wanglab2021/1.Project/00.RawData_20210817/process/script/bin/"
pathTemp="/public/home/wanglab2021/1.Project/rawdata_20220911/process/tmp"

# -----------------------------------------------------------------------------------
STARTTIME=$(date +%s)
## check input file
[ -e $REF ] || { echo "ERROR: reference genome does not exist: $REF"; exit 1 ;}
[ -e $inputVCF ] || { echo "ERROR: variant file does not exist: $inputVCF"; exit 1 ;}
[ -d $outputPath ] || mkdir -p $outputPath;
[ -d $pathREPORT ] || mkdir -p $pathREPORT;
pathTMP=$pathTemp/$STARTTIME;
[ -d $pathTMP ] || mkdir -p $pathTMP;
if [[ ! $outputName ]]; then
    if [[ $inputVCF =~ .*\.vcf\.gz$ ]]; then
        outputName=$(basename $inputVCF .vcf.gz)
        echo "outputName: $outputName"
    elif [[ $inputSNP =~ .*\.vcf$ ]]; then
        outputName=$(basename $inputVCF .vcf)
        echo "outputName: $outputName"
    else
        echo "ERROR: Please check input file, file format: *.vcf or *.vcf.gz"
        exit 1
    fi
fi
# -----------------------------------------------------------------------------------
## bgzip
#bcftools view ${inputVCF} --output-type z -o ${outputPath}/${outputName}.vcf.gz && \

## make index
if [[ ! -e $inputVCF.tbi ]]; then
    echo -n "Start to make index for ${inputVCF} at " && date && \
    ##bcftools index ${inputVCF} && \
    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" IndexFeatureFile -I ${inputVCF} && \
    echo -n "Finish to make index for ${inputVCF} at " && date
fi && \

## select SNPs
echo "Start: select SNPs at " && date && \
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" SelectVariants \
    -R $REF \
    -V ${inputVCF} \
    --select-type-to-include SNP \
    -O ${outputPath}/${outputName}_SNP.vcf.gz && \

echo "Start: select INDELs at " && date && \
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" SelectVariants \
    -R $REF \
    -V ${inputVCF} \
    --select-type-to-include INDEL \
    -O ${outputPath}/${outputName}_INDEL.vcf.gz && \

# Extract Variant Quality Scores
echo -n "Start: Extract Variant Quality Scores at " && date && \
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
    -R $REF \
    -V ${outputPath}/${outputName}_SNP.vcf.gz \
    -F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
    -O ${outputPath}/${outputName}_SNP.table && \

gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
    -R $REF \
    -V ${outputPath}/${outputName}_INDEL.vcf.gz \
    -F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
    -O ${outputPath}/${outputName}_INDEL.table && \

# Extract depth information
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
    -R $REF \
    -V ${outputPath}/${outputName}_SNP.vcf.gz \
    -F CHROM -F POS -GF GT -GF DP \
    -O ${outputPath}/${outputName}_SNP.DP.table && \

gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
    -R $REF \
    -V ${outputPath}/${outputName}_INDEL.vcf.gz \
    -F CHROM -F POS -GF GT -GF DP \
    -O ${outputPath}/${outputName}_INDEL.DP.table && \

# plot VariantsScores
[ -e ${pathSCRIPT}/plot_VariantScores.R ] || { echo "script does not exist: ${pathSCRIPT}/plot_VariantScores.R"; exit 1 ;}
Rscript ${pathSCRIPT}/plot_VariantScores.R -s ${outputPath}/${outputName}_SNP.table -i ${outputPath}/${outputName}_INDEL.table -o ${pathREPORT}/12_${outputName}_VariantsScores.pdf && \

# plot Samples Depth density
[ -e ${pathSCRIPT}/plot_SampleDepth.R ] || { echo "${pathSCRIPT}/plot_SampleDepth.R does not exist"; exit 1 ;}
mkdir ${outputPath}dp_SNP.tmp && \
mkdir ${outputPath}dp_INDEL.tmp && \
sn=$(( sampleNumber*2+1 ))
for ((i=3; i <= sn ; i +=2))
do 
    cut -f $i,$((i+1)) ${outputPath}/${outputName}_SNP.DP.table | awk '$1 != "./." {print $2}' > ${outputPath}dp_SNP.tmp/$i.DP
    cut -f $i,$((i+1)) ${outputPath}/${outputName}_INDEL.DP.table | awk '$1 != "./." {print $2}' > ${outputPath}dp_INDEL.tmp/$i.DP
done && \
Rscript ${pathSCRIPT}/plot_SampleDepth.R -i ${outputPath}dp_SNP.tmp -s $sampleNumber -o ${pathREPORT}/12_${outputName}_Samples_SNP && \
Rscript ${pathSCRIPT}/plot_SampleDepth.R -i ${outputPath}dp_INDEL.tmp -s $sampleNumber -o ${pathREPORT}/12_${outputName}_Samples_INDEL && \

\rm -r ${outputPath}dp_SNP.tmp ${outputPath}dp_INDEL.tmp $pathTMP && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."

