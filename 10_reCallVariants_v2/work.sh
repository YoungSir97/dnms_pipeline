#!/bin/bash
#ls /home/ubuntu/1.Project/DNMs/02.process.oldgenome/bam/*_sorted_bqsr.bam | perl -ne '/bam\/(.*)_mapped/ && print "$1\t$_"' > bam_bqsr.list

perl HaplotypeCaller_pipeline.pl bam_bqsr.list \
    --ref /home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa \
    --GATKprameter ' --min-base-quality-score 15 --output-mode EMIT_ALL_ACTIVE_SITES --emit-ref-confidence BP_RESOLUTION --bam-output ${BAM}_realigned.bam' \
    --outdir /home/ubuntu/1.Project/DNMs/02.process.oldgenome/vcf/10_reCallVariants2 \
    --shdir ./shell --tmpdir ./tmp


