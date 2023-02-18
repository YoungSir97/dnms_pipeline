#!/usr/bin/env perl
=head1 Usage
    perl HaplotypeCaller_pipeline.pl <bamlist> [-options]
        --ref <s>           refrence gemone, with index of GATK.
        --outdir <s>        output directory, default="./vcf".
        --outprefix <s>     prefix of output vcf file, default="". (filename: prefix + ID + suffix)
        --outsuffix <s>     suffix of output vcf file, default="_raw_snps_indels.g". (filename: prefix + ID + suffix)
        --shdir <s>         shell output directory, default="./".
        --tmpdir <s>        tmp directory.
        --GATKprameter <s>  Add or modify parameters of GATK, default="--emit-ref-confidence GVCF".
        <bamlist>           table format file with two columns (id and BAM file), example:
                                id1     /path/1.bam
                                id2     /path/2.bam
=cut
use strict;
use Cwd 'abs_path';
use Getopt::Long;
my ($help,$ref,$outdir,$shdir,$outsuffix,$tmpdir,$GATKparameter,$outprefix);
GetOptions(
    "ref:s"=>\$ref,
    "outdir:s"=>\$outdir,
    "outsuffix:s"=>\$outsuffix,
    "outprefix:s"=>\$outprefix,
    "shdir:s"=>\$shdir,
    "tmpdir:s"=>\$tmpdir,
    "GATKprameter:s"=>\$GATKparameter,
    "help!"=>\$help
);
die `pod2text $0` if (@ARGV<1 || $help);
$shdir ||= "./";
$shdir = abs_path($shdir);
-d $shdir || `mkdir -p $shdir`;
$ref ||="/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa";
-e $ref || die "ERROR! not exit reference: $ref\n";
$outdir ||= "./vcf";
$outdir = abs_path($outdir);
-d $outdir || `mkdir -p $outdir`;
$tmpdir ||= "/public/home/wanglab2021/1.Project/rawdata_20220911/tmp";
$tmpdir = abs_path($tmpdir);
-d $tmpdir || `mkdir -p $tmpdir`;
$GATKparameter ||="--emit-ref-confidence GVCF";
$outprefix ||="";
$outsuffix ||="_raw_snps_indels.g";

my $bamlist = shift;
open IN,$bamlist || die "can't open $bamlist\n";
while (<IN>){
    chomp;
    /^#/ && next;
    /^$/ && next;

    my ($id,$bamfile) = (split)[0,1];
    -e $bamfile || warn "Waring! no exit BAM file: $bamfile\n";
    print "Create shell for $id\n";
    open OUT,">$shdir/$id\_HaplotypeCaller.sh";

    print OUT "#!/bin/bash\n";
    print OUT "REF=\"$ref\"\nBAM=\"$bamfile\"\noutVCF=\"$outdir/$outprefix$id$outsuffix.vcf.gz\"\npathTMP=\"$tmpdir/$id\"\n";
    print OUT "\n# -----------------------------------------------------------------------------------\nSTARTTIME=\$(date +%s)\n";
    print OUT "# Create folder and change TMP path\n[ -d \$pathTMP ] || mkdir -p \$pathTMP\n";
    print OUT "# -----------------------------------------------------------------------------------\n# Call variants [GATK]. This will only produce a gVCF which can later be combined with\n# all the others for genotype calling.\n";
    print OUT "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" HaplotypeCaller \\
    --reference \${REF} \\
    --input \${BAM} \\
    $GATKparameter \\
    --output \${outVCF} && \\\n";
    print OUT "# -----------------------------------------------------------------------------------\necho \"Finish calling.\" && \\\nENDTIME=\$(date +%s) && \\\nTIMESPEND=\$((\$ENDTIME - \$STARTTIME)) && \\\n((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60)) && \\\ntimestamp=\$(printf \"%d:%02d:%02d\" \$hrs \$min \$sec) && \\\necho \"Took \$timestamp hours:minutes:seconds to complete...\" && \\\necho \"Still waters run deep.\"\n";
    
    close OUT;
}
close IN;

