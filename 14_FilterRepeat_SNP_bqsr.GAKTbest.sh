#!/bin/bash -e
module load apps/biosoft/bwa/0.7.17-gcc-4.5.8
module load apps/biosoft/samtools/1.12-gcc.4.8.5
module load apps/biosoft/gatk/4.1.9.0

### Set path before run shell ###
# -----------------------------------------------------------------------------------
# reference genome
REF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa"
# input variants file
inputVCF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/13_HardFilter_bqsr.GAKTbest/ALLTrios_bqsr_SNP_hardfilterPASS.vcf.gz"
# input repeat bed
inputBED="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa.masked_reapeat.bed"
# output file path and prefix
outputPath="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/14_FilterRepeat_bqsr.GAKTbest"
outputName=""  # If not set, the input file name will be used.
# samples number
sampleNumber=20
# report output path
pathREPORT="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/14_FilterRepeat_bqsr.GAKTbest/report"
# other path
pathSCRIPT="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin/"
pathTemp="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/tmp"

# -----------------------------------------------------------------------------------
STARTTIME=$(date +%s)
## check input file
[ -e $REF ] || { echo "reference genome does not exist: $REF"; exit 1 ;}
[ -e $inputVCF ] || { echo "variant file does not exist: $inputVCF"; exit 1 ;}
[ -e $inputBED ] || { echo "repeat bed file does not exist: $inputBED"; exit 1 ;}
[ -d $outputPath ] || mkdir -p $outputPath;
[ -d $pathREPORT ] || mkdir -p $pathREPORT;
pathTMP=$pathTemp/$STARTTIME
[ -d $pathTMP ] || mkdir -p $pathTMP;
if [ ! $outputName ]; then
    if [[ $inputVCF =~ .*\.vcf\.gz$ ]]; then
        outputName=$(basename $inputVCF .vcf.gz)
        echo "outputName: $outputName"
    elif [[ $inputVCF =~ .*\.vcf$ ]]; then
        outputName=$(basename $inputVCF .vcf)
        echo "outputName: $outputName"
    else
        echo "ERROE: Please check input file, file format: *.vcf or *.vcf.gz"
        exit 1
    fi
fi

# -----------------------------------------------------------------------------------
## make index
if [ ! -e $inputVCF.tbi ]; then
    echo -n "Start make index for $inputVCF at " && date && \
    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" IndexFeatureFile -I ${inputVCF} && \
    echo -n "Finish make index for $inputVCF at " && date
fi && \

## filter repetitive regions
echo -n "Start filter repeat at " && date && \
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantFiltration \
    -R $REF \
    -V ${inputVCF} \
    --mask ${inputBED} \
    --mask-name "REPEAT" \
    -O ${outputPath}/${outputName}_maskrepeat.vcf.gz && \

    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" SelectVariants \
    -R $REF \
    -V ${outputPath}/${outputName}_maskrepeat.vcf.gz \
    --exclude-filtered \
    -O ${outputPath}/${outputName}_MaskedRepeat.vcf.gz && \

\rm ${outputPath}/${outputName}_maskrepeat.vcf.gz ${outputPath}/${outputName}_maskrepeat.vcf.gz.tbi && \
echo -n "Finish filter repeat at " && date && \

## statistics
bcftools stats ${outputPath}/${outputName}_MaskedRepeat.vcf.gz > ${outputPath}/${outputName}_MaskedRepeat.stat.txt && \
perl ${pathSCRIPT}/SampleVariantCountStat.pl ${outputPath}/${outputName}_MaskedRepeat.vcf.gz > ${outputPath}/${outputName}_MaskedRepeat.sample_stat.txt && \

## Extract Variant Quality Scores
echo -n "Start: Extract Variant Quality Scores at " && date && \
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
    -R $REF \
    -V ${outputPath}/${outputName}_MaskedRepeat.vcf.gz \
    -F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
    -O ${outputPath}/${outputName}_MaskedRepeat.table && \

# Extract depth information
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
    -R $REF \
    -V ${outputPath}/${outputName}_MaskedRepeat.vcf.gz \
    -F CHROM -F POS -GF GT -GF DP \
    -O ${outputPath}/${outputName}_MaskedRepeat.DP.table && \
echo -n "Finish: Extract Variant Quality Scores at " && date && \

## plot Variant Quality Scores and Samples Depth density
[ -e ${pathSCRIPT}/plot_SampleDepth.R ] || { echo "${pathSCRIPT}/plot_SampleDepth.R does not exist"; exit 1 ;}
[ -e ${pathSCRIPT}/plot_VariantScores_SNP.R ] || { echo "script does not exist: ${pathSCRIPT}/plot_VariantScores_SNP.R"; exit 1 ;}
echo -n "Start plot Samples Depth density at " && date
Rscript ${pathSCRIPT}/plot_VariantScores_SNP.R -s ${outputPath}/${outputName}_MaskedRepeat.table -o ${pathREPORT}/14_${outputName}_MaskedRepeat_VariantScores.pdf && \

mkdir ${outputPath}/dp_MR.tmp && \
sn=$(( sampleNumber*2+1 )) && \
for ((i=3; i <= sn; i +=2))
do
    cut -f $i,$((i+1)) ${outputPath}/${outputName}_MaskedRepeat.DP.table | awk '$1 != "./." {print $2}' > ${outputPath}/dp_MR.tmp/$i.DP
done && \
Rscript ${pathSCRIPT}/plot_SampleDepth.R -i ${outputPath}/dp_MR.tmp -s 20 -o ${pathREPORT}/14_${outputName}_MaskedRepeat_SampleDepth && \
\rm -r ${outputPath}/dp_MR.tmp && \
echo -n "Finish plot Samples Depth density at " && date && \

gzip ${outputPath}/${outputName}_MaskedRepeat.table && \
gzip ${outputPath}/${outputName}_MaskedRepeat.DP.table && \
\rm -r $pathTMP && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."

