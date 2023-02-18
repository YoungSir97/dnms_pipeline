#!/bin/bash
#export PATH=/public/home/wanglab2021/software/glu-1.0b3-prerelease4-Linux_x86-64/:$PATH
export PATH=/home/ubuntu/software/plink-v1.90/:$PATH
export PATH=/home/ubuntu/software/gcta-v1.94.1/:$PATH

inputVCF="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/ALLTrios_bqsr_snps_indels_GENOME.vcf.gz"
sampleInfo="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin/sample_info.txt"
pathTemp="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/tmp/"
outputPath="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/11_PCA"
outFileName="all.vcf.pca"
pathSCRIPT="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin"

STARTTIME=$(date +%s)
# ----------------------------------------------------------------------------------------------------------
#0. check input file
[ -e $inputVCF ] || { echo "ERROR: variant file does not exist: $inputVCF"; exit 1 ;}
[ -e $sampleInfo ] || { echo "ERROR: sample file does not exist: $sampleInfo"; exit 1 ;}
[ -d $outputPath ] || mkdir -p $outputPath;
[ -e $pathSCRIPT/11_plot_SNPs_PCA.R ] || { echo "ERROR: $pathSCRIPT/11_plot_SNPs_PCA.R does not exist"; exit 1 ;}
pathTMP=$pathTemp/$STARTTIME
[ -d $pathTMP ] || mkdir -p $pathTMP;
if [ ! $outFileName ]; then
    if [[ $inputVCF =~ .*\.vcf\.gz$ ]]; then
        outFileName=$(basename $inputVCF .vcf.gz)
        echo "outFileName: $outFileName"
    elif [[ $inputVCF =~ .*\.vcf$ ]]; then
        outFileName=$(basename $inputVCF .vcf)
        echo "outFileName: $outFileName"                                   
    else
        echo "ERROE: Please check input file, file format: *.vcf or *.vcf.gz"
        exit 1
    fi
fi

#1. convert vcf file to map file
vcftools --gzvcf ${inputVCF} --plink --out ${outputPath}/${outFileName} && \

#2. convert hapmap to plink file (.bed)
plink --noweb --file ${outputPath}/${outFileName} --maf 0.05 --make-bed --out ${outputPath}/${outFileName}_bfile && \

#3. PCA & GCTA-GRM: calculating the genetic relationship matrix (GRM) from all the autosomal SNPs
gcta --bfile ${outputPath}/${outFileName}_bfile --make-grm --autosome --maf 0.01 --out ${outputPath}/${outFileName}_bfile_grm && \
gcta --grm ${outputPath}/${outFileName}_bfile_grm --pca 20 --out ${outputPath}/${outFileName}_bfile_grm_pca && \

##4. R for PCA plot
Rscript ${pathSCRIPT}/11_plot_SNPs_PCA.R -i ${outputPath} -p ${outFileName}_bfile_grm_pca -s ${sampleInfo} && \

# ----------------------------------------------------------------------------------------------------------
## remove sample F07074
##bcftools view ${pathVCF}ALLTrios_mapped_fixmate_sorted_bqsr_raw_snps_GENOME.vcf.gz -s ^F07074 -o ${pathPCA}tmp.vcf
#vcftools --vcf ${pathPCA}tmp.vcf --plink --out ${pathPCA}tmp.vcf.pca && \
#plink --noweb --file ${pathPCA}tmp.vcf.pca --maf 0.05 --make-bed --out ${pathPCA}tmp.vcf.pca_bfile && \
#gcta --bfile ${pathPCA}tmp.vcf.pca_bfile --make-grm --autosome --maf 0.01 --out ${pathPCA}tmp.vcf.pca_bfile_grm && \
#gcta --grm ${pathPCA}tmp.vcf.pca_bfile_grm --pca 10 --out ${pathPCA}raw_snp_pca && \

# ----------------------------------------------------------------------------------------------------------
ENDTIME=$(date +%s) && \
TIMESPEND=$(($ENDTIME - $STARTTIME)) && \
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec) && \
echo "Took $timestamp hours:minutes:seconds to complete..." && \
echo "Still waters run deep."

