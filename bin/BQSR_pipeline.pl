#!/usr/bin/env perl
=head1 Usage
    perl BQSR_pipeline.pl <bamlist> [-options]
        --knownsites <s>    known sites
        --ref <s>           refrence gemone, with index of GATK.
        --outdir <s>        output directory, default="./bam".
        --outprefix <s>     prefix of output vcf file, default="". (filename: prefix + ID + suffix)
        --outsuffix <s>     suffix of output vcf file, default="_mapped_fixmate_sorted_bqsr". (filename: prefix + ID + suffix)
        --shdir <s>         shell output directory, default="./".
        --tmpdir <s>        tmp directory.
        <bamlist>           table format file with two columns (id and BAM file), example:
                                id1     /path/1.bam
                                id2     /path/2.bam
=cut
use strict;
use Cwd 'abs_path';
use Getopt::Long;
my ($help,$ref,$outdir,$shdir,$outsuffix,$tmpdir,$outprefix,$knownsites);
GetOptions(
    "knownsites:s"=>\$knownsites,
    "ref:s"=>\$ref,
    "outdir:s"=>\$outdir,
    "outsuffix:s"=>\$outsuffix,
    "outprefix:s"=>\$outprefix,
    "shdir:s"=>\$shdir,
    "tmpdir:s"=>\$tmpdir,
    "help!"=>\$help
);
die `pod2text $0` if (@ARGV<1 || $help);
$shdir ||= "./";
$shdir = abs_path($shdir);
-d $shdir || `mkdir -p $shdir`;
$knownsites ||="/public/home/wanglab2021/1.Project/rawdata_20220911/vcf/08_HardFilter/TRUESITES.vcf.gz";
-e $knownsites || die "ERROR! not exit known sites: $knownsites\n";
$ref ||="/public/home/wanglab2021/1.Project/rawdata_20220911/refgenome_3.2.4/Zebrafinch.rename.fa";
-e $ref || die "ERROR! not exit reference: $ref\n";
$outdir ||= "./bam";
$outdir =~ s/\/$//;
$outdir = abs_path($outdir);
-d $outdir || `mkdir -p $outdir`;
$tmpdir ||= "/public/home/wanglab2021/1.Project/rawdata_20220911/tmp";
$tmpdir =~ s/\/$//;
$tmpdir = abs_path($tmpdir);
-d $tmpdir || `mkdir -p $tmpdir`;
$outprefix ||="";
$outsuffix ||="_mapped_fixmate_sorted_bqsr";

my $bamlist = shift;
open IN,$bamlist || die "can't open $bamlist\n";
while (<IN>){
    chomp;
    /^#/ && next;
    /^$/ && next;

    my ($id,$bamfile) = (split)[0,1];
    -e $bamfile || warn "Waring! no exit BAM file: $bamfile\n";
    print "Create shell for $id\n";
    open OUT,">$shdir/$id\_BQSR.sh";

    print OUT "#!/bin/bash\n";
    print OUT "\n# -----------------------------------------------------------------------------------\n# manual options\n";
    print OUT "REF=\"$ref\"\nBAM=\"$bamfile\"\noutBAM=\"$outdir/$outprefix$id$outsuffix.bam\"\nKNOWNSITES=\"$knownsites\"\npathTMP=\"$tmpdir/$id\"\n";
    print OUT "\n# -----------------------------------------------------------------------------------\nSTARTTIME=\$(date +%s)\n";
    print OUT "# Create folder and change TMP path\n[ -d \$pathTMP ] || mkdir -p \$pathTMP\n";
    print OUT "# -----------------------------------------------------------------------------------\n# Base quality recalibration. We do this last, because we want all the data to be as clean as possible when we get here [GATK]\n";
    print OUT "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" BaseRecalibrator \\
    --reference \${REF} \\
    --input \${BAM} \\
    --known-sites \${KNOWNSITES} \\
    --output \${BAM}_recal_data.table && \\

gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" ApplyBQSR \\
    --reference \${REF} \\
    --input \${BAM} \\
    --bqsr-recal-file \${BAM}_recal_data.table \\
    --create-output-bam-index true \\
    --output \${outBAM} && \\\n";

    print OUT "# -----------------------------------------------------------------------------------\n#Check BAM/mapping-quality [BamQC, BAMStats]\n";
    print OUT "qualimap bamqc -bam \${outBAM} --java-mem-size=32G -outdir \${outBAM}_bamqc && \\\n";
    print OUT "# -----------------------------------------------------------------------------------\n# Remove all intermediate files\n#\\rm \${BAM} \${BAM}.* && \\\n\\rm -r \${pathTMP} && \\\n";
    print OUT "# -----------------------------------------------------------------------------------\nENDTIME=\$(date +%s) && \\\nTIMESPEND=\$((\$ENDTIME - \$STARTTIME)) && \\\n((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \\\ntimestamp=\$(printf \"%d:%02d:%02d\" \$hrs \$min \$sec) && \\\necho \"Took \$timestamp hours:minutes:seconds to complete...\" && \\\necho \"Still waters run deep.\"\n";
    close OUT;
}
close IN;

