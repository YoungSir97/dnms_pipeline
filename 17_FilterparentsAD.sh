#!/bin/bash
ref="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa"
bamdir="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/bam/bam_raw"
outdir="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/16_SpecificFilter_bqsr.GAKTbest/Step6_FilterParentsAD_output/"

for i in /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/16_SpecificFilter_bqsr.GAKTbest/Step5_FilterADalt_output/Fam*.GT.DP.AB.GQ.AD.vcf.gz
do
    fid=`echo "$i" | perl -ne '/Fam\d+_F\d+_(F\d+)_F\d+.GT.DP.AB.GQ.AD.vcf.gz/ && print "$1"'`
    mid=`echo "$i" | perl -ne '/Fam\d+_F\d+_F\d+_(F\d+).GT.DP.AB.GQ.AD.vcf.gz/ && print "$1"'`
    filename=`echo "$i" | perl -ne '/(Fam\d+_F\d+_F\d+_F\d+).GT.DP.AB.GQ.AD.vcf.gz/ && print "$1"'`
    echo "$fid $mid $filename";

    perl /home/ubuntu/1.Project/DNMs/02.process.oldgenome/script/bin/parent_alternative_reads_filter.pl $i --ref $ref --fbam $bamdir/$fid\_mapped_fixmate_sorted.bam --mbam $bamdir/$mid\_mapped_fixmate_sorted.bam --outdir $outdir > $outdir/$filename.final.vcf
    bcftools stats $outdir/$filename.final.vcf > $outdir/$filename.final.vcf.stat.txt

done


