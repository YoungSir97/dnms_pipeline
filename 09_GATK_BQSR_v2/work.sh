#!/bin/bash
#ls /public/home/wanglab2021/1.Project/rawdata_20220911/bam/*_sorted.bam | perl -ne '/bam\/(.*)_mapped/ && print "$1\t$_"' > bam.list

### create shell
#perl BQSR_pipeline.pl --help
perl BQSR_pipeline.pl bam.list \
    --ref /home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa \
    --outdir /home/ubuntu/1.Project/DNMs/02.process.oldgenome/bam_bqsr/ \
    --shdir ./shell --tmpdir ./tmp \
    -knownsites /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/08_HardFilter/TRUESITES.vcf.gz


