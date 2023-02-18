#!/bin/bash
#ls /public/home/wanglab2021/1.Project/rawdata_20220911/bam/*_sorted.bam | perl -ne '/bam\/(.*)_mapped/ && print "$1\t$_"' > bam.list

perl HaplotypeCaller_pipeline.pl bam.list --outdir outvcf --shdir shell --tmpdir ./tmp


