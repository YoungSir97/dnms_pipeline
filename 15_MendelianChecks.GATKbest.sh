#!/bin/bash
module load apps/biosoft/gatk/4.1.9.0
module load apps/biosoft/bcftools/1.12-gcc4.8.5

### Set path before run shell ###
# -----------------------------------------------------------------------------------
# reference genome
REF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa"
# input variants file
inputVCF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/14_FilterRepeat_bqsr.GAKTbest/ALLTrios_bqsr_SNP_hardfilterPASS_MaskedRepeat.vcf.gz"
# input repeat bed
inputPED="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/pedigree/family_trios.ped"
# output file path and prefix
outputPath="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/15_MendelianCheck_bqsr.GAKTbest"
outputName=""  # If not set, the input file name will be used.
# samples number
sampleNumber=20
# report output path
pathREPORT="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/15_MendelianCheck_bqsr.GAKTbest/report"
# other path
pathSCRIPT="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin/"
pathTemp="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/tmp"

# -----------------------------------------------------------------------------------
STARTTIME=$(date +%s)
## check input file
[ -e $inputVCF ] || { echo "ERROR: variant file does not exist: $inputVCF"; exit 1 ;}
[ -e $inputPED ] || { echo "ERROR: repeat bed file does not exist: $inputPED"; exit 1 ;}
[ -d $outputPath ] || mkdir -p $outputPath;
[ -d $pathREPORT ] || mkdir -p $pathREPORT;
[ -e $pathSCRIPT/SampleVariantCountStat.pl ] || { echo "ERROR: $pathSCRIPT/SampleVariantCountStat.pl does not exist"; exit 1 ;}
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

echo -n "Start mendelian check at " && date && \
## Mendelian check summary
bcftools +mendelian ${inputVCF} -p ${inputPED} -m c > ${outputPath}/${outputName}_MendelianCheck.summary.txt && \
## output consistent sites
bcftools +mendelian ${inputVCF} -p ${inputPED} -m d --output-type z --output ${outputPath}/${outputName}_MendelianConsistent.vcf.gz && \
## output inconsistent sites
bcftools +mendelian ${inputVCF} -p ${inputPED} -m x --output-type z --output ${outputPath}/${outputName}_MendelianViolation.vcf.gz && \
echo -n "Finish mendelian check at " && date && \

## statistics
bcftools stats ${outputPath}/${outputName}_MendelianConsistent.vcf.gz > ${outputPath}/${outputName}_MendelianConsistent.stat.txt && \
perl ${pathSCRIPT}/SampleVariantCountStat.pl ${outputPath}/${outputName}_MendelianConsistent.vcf.gz > ${outputPath}/${outputName}_MendelianConsistent.sample_stat.txt && \

bcftools stats ${outputPath}/${outputName}_MendelianViolation.vcf.gz > ${outputPath}/${outputName}_MendelianViolation.stat.txt && \
perl ${pathSCRIPT}/SampleVariantCountStat.pl ${outputPath}/${outputName}_MendelianViolation.vcf.gz > ${outputPath}/${outputName}_MendelianViolation.sample_stat.txt && \

## make index
if [ ! -e ${outputPath}/${outputName}_MendelianViolation.vcf.gz.tbi ]; then
    echo -n "Start make index for $inputVCF at " && date && \
    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" IndexFeatureFile -I ${outputPath}/${outputName}_MendelianViolation.vcf.gz && \
    echo -n "Finish make index for $inputVCF at " && date
fi && \

## Extract Variant Quality Scores
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
    -R $REF \
    -V ${outputPath}/${outputName}_MendelianViolation.vcf.gz \
    -F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
    -O ${outputPath}/${outputName}_MendelianViolation.table && \

# Extract depth information
gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
    -R $REF \
    -V ${outputPath}/${outputName}_MendelianViolation.vcf.gz \
    -F CHROM -F POS -GF GT -GF DP \
    -O ${outputPath}/${outputName}_MendelianViolation.DP.table && \
echo -n "Finish: Extract Variant Quality Scores at " && date && \

## plot Variant Quality Scores and Samples Depth density
[ -e ${pathSCRIPT}/plot_SampleDepth.R ] || { echo "${pathSCRIPT}/plot_SampleDepth.R does not exist"; exit 1 ;}
[ -e ${pathSCRIPT}/plot_VariantScores_SNP.R ] || { echo "script does not exist: ${pathSCRIPT}/plot_VariantScores_SNP.R"; exit 1 ;}
echo -n "Start plot Samples Depth density at " && date
Rscript ${pathSCRIPT}/plot_VariantScores_SNP.R -s ${outputPath}/${outputName}_MendelianViolation.table -o ${pathREPORT}/15_${outputName}_MV_VariantScores.pdf && \

mkdir ${outputPath}/dp_MR.tmp && \
sn=$(( sampleNumber*2+1 )) && \
for ((i=3; i <= sn; i +=2))
do
    cut -f $i,$((i+1)) ${outputPath}/${outputName}_MendelianViolation.DP.table | awk '$1 != "./." {print $2}' > ${outputPath}/dp_MR.tmp/$i.DP
done && \
Rscript ${pathSCRIPT}/plot_SampleDepth.R -i ${outputPath}/dp_MR.tmp -s 20 -o ${pathREPORT}/15_${outputName}_MV_SampleDepth && \
\rm -r ${outputPath}/dp_MR.tmp && \
echo -n "Finish plot Samples Depth density at " && date && \
gzip ${outputPath}/${outputName}_MendelianViolation.table && \
gzip ${outputPath}/${outputName}_MendelianViolation.DP.table && \
\rm -r $pathTMP && \

# ----------------------------------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."

