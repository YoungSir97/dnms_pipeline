#!/bin/bash -e
# -----------------------------------------------------------------------------------
# This script is to filter variant with GATK's Best Practises hard filter criteria.
# You must to set parameters manually before running it.
# Version: v1.0,  Date: 2022-03-05,  Author: Ys, shuaiyang.bio@gmail.com
# -----------------------------------------------------------------------------------
### Set parameters manually ###
# reference genome
REF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa"
# input variants file(.vcf), at least one of [inputSNP inputINDEL].
inputSNP="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/12_SelectVariants_bqsr/ALLTrios_bqsr_raw_SNP.vcf.gz"
inputINDEL="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/12_SelectVariants_bqsr/ALLTrios_bqsr_raw_INDEL.vcf.gz"
# output path and prefix
outputPath="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/13_HardFilter_bqsr.GAKTbest"
outNameSNP="ALLTrios_bqsr_SNP" # If not set, the input file name will be used.
outNameINDEL="ALLTrios_bqsr_INDEL" # If not set, the input file name will be used.
# report file output path
pathREPORT="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/13_HardFilter_bqsr.GAKTbest/report"
# Number of samples in variants file(.vcf)
sampleNumber=20
# other path
pathSCRIPT="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin"
pathTemp="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/tmp"

# -----------------------------------------------------------------------------------
STARTTIME=$(date +%s)
## check input file
[ -e $REF ] || { echo "reference genome does not exist: $REF"; exit 1 ;}
if [ ! $inputSNP ] && [ ! $inputINDEL]; then
    echo "no input file"
    exit 1;
fi
[ -d $outputPath ] || mkdir -p $outputPath;
[ -d $pathREPORT ] || mkdir -p $pathREPORT;
pathTMP=$pathTemp/$STARTTIME;
[ -d $pathTMP ] || mkdir -p $pathTMP;
[ -e ${pathSCRIPT}/plot_SampleDepth.R ] || { echo "script does not exist: ${pathSCRIPT}/plot_SampleDepth.R"; exit 1 ;}
sn=$(( sampleNumber*2+1 ))

## filter SNPs with GATK's Best Practises hard filter criteria (MQ < 40.0; QD < 2.0; FS > 60.0; MQRankSum < -12.5; ReadPosRankSum < -8.0)
if [ $inputSNP ]; then
    # check input
    [ -e $inputSNP ] || { echo "input SNP file does not exist: $inputSNP"; exit 1 ;}
    if [ ! $outNameSNP ]; then
        if [[ $inputSNP =~ .*\.vcf\.gz$ ]]; then
            outNameSNP=$(basename $inputSNP .vcf.gz)
            echo "outNameSNP: $outNameSNP"
        elif [[ $inputSNP =~ .*\.vcf$ ]]; then
            outNameSNP=$(basename $inputSNP .vcf)
            echo "outNameSNP: $outNameSNP"
        else
            echo "ERROE: Please check input file, file format: *.vcf or *.vcf.gz"
            exit 1
        fi
    fi

    ## make index
    if [ ! -e $inputSNP.tbi ]; then
        echo -n "Start make index for $inputSNP at " && date && \
        gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" IndexFeatureFile -I ${inputSNP} && \
        echo -n "Finish make index for $inputSNP at " && date
    fi && \

    ## run hard filter
    echo -n "Start hard filter for SNPs at:" && date && \
    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantFiltration \
        -R $REF \
        -V ${inputSNP} \
        --filter-expression 'MQ < 40.0 || QD < 2.0 || FS > 60.0 || SOR > 3.0 || MQRankSum < -12.50 || ReadPosRankSum < -8.000' \
        --filter-name 'snp_hard_filter' \
        -O ${outputPath}/${outNameSNP}_hardfilter.vcf.gz && \

    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" SelectVariants \
        -R $REF \
        -V ${outputPath}/${outNameSNP}_hardfilter.vcf.gz \
        --exclude-filtered \
        -O ${outputPath}/${outNameSNP}_hardfilterPASS.vcf.gz && \

    \rm ${outputPath}/${outNameSNP}_hardfilter.vcf.gz ${outputPath}/${outNameSNP}_hardfilter.vcf.gz.tbi && \
    echo -n "Finish hard filter for SNPs at:" && date && \

    ## statistics
    bcftools stats ${outputPath}/${outNameSNP}_hardfilterPASS.vcf.gz > ${outputPath}/${outNameSNP}_hardfilterPASS.stat.txt && \
    perl ${pathSCRIPT}/SampleVariantCountStat.pl -t SNP ${outputPath}/${outNameSNP}_hardfilterPASS.vcf.gz > ${outputPath}/${outNameSNP}_hardfilterPASS.sample_stat.txt && \

    ## Extract Variant Quality Scores
    echo -n "Start: Extract Variant Quality Scores for SNPs at " && date && \
    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
        -R $REF \
        -V ${outputPath}/${outNameSNP}_hardfilterPASS.vcf.gz \
        -F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
        -O ${outputPath}/${outNameSNP}_hardfilterPASS.table && \

    # Extract depth information
    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
        -R $REF \
        -V ${outputPath}/${outNameSNP}_hardfilterPASS.vcf.gz \
        -F CHROM -F POS -GF GT -GF DP \
        -O ${outputPath}/${outNameSNP}_hardfilterPASS.DP.table && \
    echo -n "Finish: Extract Variant Quality Scores for SNPs at " && date && \

    ## plot Samples Depth density
    mkdir ${outputPath}/dp_SNPs.tmp && \
    for ((i=3; i <= sn; i +=2))
    do
        cut -f $i,$((i+1)) ${outputPath}/${outNameSNP}_hardfilterPASS.DP.table | awk '$1 != "./." {print $2}' > ${outputPath}/dp_SNPs.tmp/$i.DP
    done && \
    Rscript ${pathSCRIPT}/plot_SampleDepth.R -i ${outputPath}/dp_SNPs.tmp -s 20 -o ${pathREPORT}/13_HardFilter_Samples_SNP && \
    \rm -r ${outputPath}/dp_SNPs.tmp && \
    echo -n "Finish plot Samples SNP Depth density at " && date
fi && \

## filter INDELs with GATK's Best Practises hard filter criteria (QD < 2.0; FS > 200.0; QUAL < 30.0; ReadPosRankSum < -20.0)
if [ $inputINDEL ]; then
    # check input
    [ -e $inputINDEL ] || { echo "input INDEL file does not exist: $inputINDEL"; exit 1 ;}
    if [ !$outNameINDEL ]; then
        if [[ $inputINDEL =~ .*\.vcf\.gz$ ]]; then
            outNameINDEL=$(basename $inputINDEL .vcf.gz)
            echo "outNameINDEL: $outNameINDEL"
        elif [[ $inputINDEL =~ .*\.vcf$ ]]; then
            outNameINDEL=$(basename $inputINDEL .vcf)
            echo "outNameINDEL: $outNameINDEL"
        else
            echo "ERROE: Please check input file, file format: *.vcf or *.vcf.gz"
            exit 1
        fi
    fi

    # make index
    if [ ! -e $inputINDEL.tbi ]; then
        echo -n "Start to make index for $inputINDEL at" && date && \
        gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" IndexFeatureFile -I ${inputINDEL} && \
        echo -n "Finish to make index for $inputINDEL at" && date
    fi && \

    ## run hard filter
    echo -n "Start hard filter for INDELs at:" && date && \
    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantFiltration \
        -R $REF \
        -V ${inputINDEL} \
        --filter-expression 'QD < 2.0 || FS > 200.0 || QUAL < 30.0 || ReadPosRankSum < -20.000' \
        --filter-name 'indel_hard_filter' \
        -O ${outputPath}/${outNameINDEL}_hardfilter.vcf.gz && \

    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" SelectVariants \
        -R $REF \
        -V ${outputPath}/${outNameINDEL}_hardfilter.vcf.gz \
        --exclude-filtered \
        -O ${outputPath}/${outNameINDEL}_hardfilterPASS.vcf.gz && \

    \rm ${outputPath}/${outNameINDEL}_hardfilter.vcf.gz ${outputPath}/${outNameINDEL}_hardfilter.vcf.gz.tbi && \
    echo -n "Finish hard filter for INDELs at:" && date && \
    
    ## statistics
    bcftools stats ${outputPath}/${outNameINDEL}_hardfilterPASS.vcf.gz > ${outputPath}/${outNameINDEL}_hardfilterPASS.stat.txt && \
    perl ${pathSCRIPT}/SampleVariantCountStat.pl -t INDEL ${outputPath}/${outNameINDEL}_hardfilterPASS.vcf.gz > ${outputPath}/${outNameINDEL}_hardfilterPASS.sample_stat.txt

    ## Extract Variant Quality Scores
    echo -n "Start: Extract Variant Quality Scores for INDELs at " && date && \
    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
        -R $REF \
        -V ${outputPath}/${outNameINDEL}_hardfilterPASS.vcf.gz \
        -F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
        -O ${outputPath}/${outNameINDEL}_hardfilterPASS.table && \

    ## Extract depth information
    gatk --spark-runner LOCAL --java-options "-Djava.io.tmpdir=${pathTMP}" VariantsToTable \
        -R $REF \
        -V ${outputPath}/${outNameINDEL}_hardfilterPASS.vcf.gz \
        -F CHROM -F POS -GF GT -GF DP \
        -O ${outputPath}/${outNameINDEL}_hardfilterPASS.DP.table && \
    echo -n "Finish: Extract Variant Quality Scores for INDELs at " && date && \
    
    ## plot Samples Depth density
    mkdir ${outputPath}/dp_INDELs.tmp && \
    for ((i=3; i <= sn; i +=2))
    do  
        cut -f $i,$((i+1)) ${outputPath}/${outNameINDEL}_hardfilterPASS.DP.table | awk '$1 != "./." {print $2}' > ${outputPath}/dp_INDELs.tmp/$i.DP
    done && \
    Rscript ${pathSCRIPT}/plot_SampleDepth.R -i ${outputPath}/dp_INDELs.tmp -s 20 -o ${pathREPORT}/13_HardFilter_Samples_INDEL && \
    \rm -r ${outputPath}/dp_INDELs.tmp && \
    echo -n "Finish plot Samples INDEL Depth density at " && date
fi && \

## plot VariantsScores
if [ $inputSNP ] && [ $inputINDEL ]; then
    [ -e ${pathSCRIPT}/plot_VariantScores.R ] || { echo "script does not exist: ${pathSCRIPT}/plot_VariantScores.R"; exit 1 ;}
    Rscript ${pathSCRIPT}/plot_VariantScores.R -s ${outputPath}/${outNameSNP}_hardfilterPASS.table -i ${outputPath}/${outNameINDEL}_hardfilterPASS.table -o ${pathREPORT}/13_HardFilter_VariantsScores.pdf
elif [ $inputSNP ] && [ ! $inputINDEL ]; then
    [ -e ${pathSCRIPT}/plot_VariantScores_SNP.R ] || { echo "script does not exist: ${pathSCRIPT}/plot_VariantScores_SNP.R"; exit 1 ;}
    Rscript ${pathSCRIPT}/plot_VariantScores_SNP.R -s ${outputPath}/${outNameSNP}_hardfilterPASS.table -o ${pathREPORT}/13_HardFilter_VariantsScores_SNP.pdf
elif [ ! $inputSNP ] && [ $inputINDEL ]; then
    [ -e ${pathSCRIPT}/plot_VariantScores_INDEL.R ] || { echo "script does not exist: ${pathSCRIPT}/plot_VariantScores_INDEL.R"; exit 1 ;}
    Rscript ${pathSCRIPT}/plot_VariantScores_INDEL.R -i ${outputPath}/${outNameINDEL}_hardfilterPASS.table -o ${pathREPORT}/13_HardFilter_VariantsScores_INDEL.pdf
fi && \

\rm -r $pathTMP && \

# -----------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."

