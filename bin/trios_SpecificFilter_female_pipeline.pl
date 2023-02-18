#!/usr/bin/env perl
=head1 Usage
    perl trios_SpecificFilter_pipeline.pl <vcf> <ped>
    --outdir <str>          output directory of shell and result
    --tmpdir <str>          tmp dir
        --coverage <int>    filter sequecing depth with coverage*0.5 < DP < coverage*2, default=50
        --DPlist            a list containing maximum DP and minimum DP
        --GQ <num>          threshold of Genotype Quality, default=40

=head1 Example
    perl trios_SpecificFilter_pipeline.pl ./test.vcf ./test.ped -o ./output -t ./output/tmp
    (Then, `cd output` and `bash step1.sh` ... )
=cut
use strict;
use Cwd 'abs_path';
use Getopt::Long;
my ($help,$outdir,$tmpdir,$coverage,$cutGQ,$DPlist);
GetOptions(
    "outdir:s"=>\$outdir,
    "coverage:i"=>\$coverage,
    "DPlist:s"=>\$DPlist,
    "GQ:n"=>\$cutGQ,
    "tmpdir:s"=>\$tmpdir,
    "help!"=>\$help
);
die `pod2text $0` if (@ARGV<2 || $help);
$outdir ||= "./";
$outdir = abs_path($outdir);
$coverage ||= 50;
my $minDP = $coverage*0.5;
my $maxDP = $coverage*2;
$cutGQ ||=40;
$tmpdir ||= "/public/home/wanglab2021/1.Project/00.RawData_20210817/process/tmp";
$tmpdir = abs_path($tmpdir);
-e $tmpdir || `mkdir -p $tmpdir`;

my %D;
if ($DPlist){
    open IN,"$DPlist";
    # id    minDP   maxDP
    while (<IN>){
        chomp;
        my @l = split;
        $D{$l[0]}{1}=$l[1];
        $D{$l[0]}{2}=$l[2];
    }
    close IN;
}

my $vcf = shift;
-e $vcf || die "ERROR: $vcf not exist\n";
$vcf = abs_path($vcf);
my $pedfile = shift;

## read ped file, save to hash
my %trios;
open IN,$pedfile || die $!;
while (<IN>){
    chomp;
    /^$/ && next;
    /^#/ && next;

    my @a = split /\s+/,$_;
    die "ERROR: check ped file format\n" if (@a != 6);
    my @tmptrios = ($a[1],$a[2],$a[3]);
    $trios{$a[0]} = \@tmptrios;
    #print "$trios{$a[0]}\n";
}
close IN;


## make shell script
-d $outdir || `mkdir -p $outdir`;

my $output1 = "$outdir/Step1_SelectTrioGT_output";
#-d $output1 || mkdir -p $output1;
open SH1,">$outdir/Step1_SelectTrioGT.sh" || die $!;
print SH1 "#!/bin/bash\n\n";
print SH1 "mkdir -p $output1\npathTMP=\"$tmpdir\"\n\n";

my $output2 = "$outdir/Step2_FilterDepth_output";
open SH2,">$outdir/Step2_FilterDepth.sh" || die $!;
print SH2 "#!/bin/bash\n\n";
print SH2 "mkdir -p $output2\npathTMP=\"$tmpdir\"\n\n";

my $output4 = "$outdir/Step3_FilterGenotypeQuality_output";
open SH4,">$outdir/Step3_FilterGenotypeQuality.sh" || die $!;
print SH4 "#!/bin/bash\n\n";
print SH4 "mkdir -p $output4\npathTMP=\"$tmpdir\"\n\n";

my $output5 = "$outdir/Step4_FilterADalt_output";
open SH5,">$outdir/Step4_FilterADalt.sh" || die $!;
print SH5 "#!/bin/bash\n\n";
print SH5 "mkdir -p $output5\npathTMP=\"$tmpdir\"\n\n";

foreach my $fam ( sort keys %trios){
    my @t = @{$trios{$fam}};
    print "$fam: $t[0],$t[1],$t[2]\n";  #child(ZW) father(ZZ) mother(ZW)

    #chrZ
    print SH1 "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" SelectVariants -V $vcf --intervals chrZ -select 'vc.getGenotype(\"$t[1]\").isHomRef() && vc.getGenotype(\"$t[0]\").isHomVar()' --exclude-filtered true -O $output1/$fam\_$t[0]_$t[1]_$t[2].Z.tmp.vcf.gz && \\\nbcftools view -s $t[0],$t[1],$t[2] $output1/$fam\_$t[0]_$t[1]_$t[2].Z.tmp.vcf.gz --output-type z -o $output1/$fam\_$t[0]_$t[1]_$t[2].Z.vcf.gz && \\\n\\rm $output1/$fam\_$t[0]_$t[1]_$t[2].Z.tmp.vcf.gz && \\\n";
    print SH1 "bcftools stats $output1/$fam\_$t[0]_$t[1]_$t[2].Z.vcf.gz > $output1/$fam\_$t[0]_$t[1]_$t[2].Z.vcf.gz.stat.txt\n\n";
    #chrW
    print SH1 "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" SelectVariants -V $vcf --intervals chrW -select 'vc.getGenotype(\"$t[2]\").isHomRef() && vc.getGenotype(\"$t[0]\").isHomVar()' --exclude-filtered true -O $output1/$fam\_$t[0]_$t[1]_$t[2].W.tmp.vcf.gz && \\\nbcftools view -s $t[0],$t[1],$t[2] $output1/$fam\_$t[0]_$t[1]_$t[2].W.tmp.vcf.gz --output-type z -o $output1/$fam\_$t[0]_$t[1]_$t[2].W.vcf.gz && \\\n\\rm $output1/$fam\_$t[0]_$t[1]_$t[2].W.tmp.vcf.gz && \\\n";
    print SH1 "bcftools stats $output1/$fam\_$t[0]_$t[1]_$t[2].W.vcf.gz > $output1/$fam\_$t[0]_$t[1]_$t[2].W.vcf.gz.stat.txt\n\n";

    if ($DPlist){
        #chrZ
        print SH2 "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" IndexFeatureFile -I $output1/$fam\_$t[0]_$t[1]_$t[2].Z.vcf.gz && \\\ngatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" SelectVariants -V $output1/$fam\_$t[0]_$t[1]_$t[2].Z.vcf.gz -select 'vc.getGenotype(\"$t[1]\").getDP() >=$D{$t[1]}{1} && vc.getGenotype(\"$t[0]\").getDP()*2 >=$D{$t[0]}{1} && vc.getGenotype(\"$t[1]\").getDP() <=$D{$t[1]}{2} && vc.getGenotype(\"$t[0]\").getDP()*2 <=$D{$t[0]}{2}' --exclude-filtered true -O $output2/$fam\_$t[0]_$t[1]_$t[2].Z.DP.vcf.gz && \\\nbcftools stats $output2/$fam\_$t[0]_$t[1]_$t[2].Z.DP.vcf.gz > $output2/$fam\_$t[0]_$t[1]_$t[2].Z.DP.vcf.gz.stat.txt\n\n";
        #chrW
        print SH2 "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" IndexFeatureFile -I $output1/$fam\_$t[0]_$t[1]_$t[2].W.vcf.gz && \\\ngatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" SelectVariants -V $output1/$fam\_$t[0]_$t[1]_$t[2].W.vcf.gz -select 'vc.getGenotype(\"$t[2]\").getDP()*2 >=$D{$t[2]}{1} && vc.getGenotype(\"$t[0]\").getDP()*2 >=$D{$t[0]}{1} && vc.getGenotype(\"$t[2]\").getDP()*2 <=$D{$t[2]}{2} && vc.getGenotype(\"$t[0]\").getDP()*2 <=$D{$t[0]}{2}' --exclude-filtered true -O $output2/$fam\_$t[0]_$t[1]_$t[2].W.DP.vcf.gz && \\\nbcftools stats $output2/$fam\_$t[0]_$t[1]_$t[2].W.DP.vcf.gz > $output2/$fam\_$t[0]_$t[1]_$t[2].W.DP.vcf.gz.stat.txt\n\n";
    }else{
        warn "check\n";
        #print SH2 "gatk --spark-runner am\_$t[0]_$t[1]_$t[2].GT.vcf.gz && \\\ngatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" SelectVariants -V $output1/$fam\_$t[0]_$t[1]_$t[2].GT.vcf.gz -select 'vc.getGenotype(\"$t[2]\").getDP() >=$minDP && vc.getGenotype(\"$t[1]\").getDP() >=$minDP && vc.getGenotype(\"$t[0]\").getDP() >=$minDP && vc.getGenotype(\"$t[2]\").getDP() <=$maxDP && vc.getGenotype(\"$t[1]\").getDP() <=$maxDP && vc.getGenotype(\"$t[0]\").getDP() <=$maxDP' --exclude-filtered true -O $output2/$fam\_$t[0]_$t[1]_$t[2].GT.DP.vcf.gz && \\\nbcftools stats $output2/$fam\_$t[0]_$t[1]_$t[2].GT.DP.vcf.gz > $output2/$fam\_$t[0]_$t[1]_$t[2].GT.DP.vcf.gz.stat.txt\n\n";
    }
    
    #chrZ
    print SH4 "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" SelectVariants -V $output2/$fam\_$t[0]_$t[1]_$t[2].Z.DP.vcf.gz -select 'vc.getGenotype(\"$t[1]\").getGQ() >=$cutGQ && vc.getGenotype(\"$t[0]\").getGQ() >=$cutGQ' --exclude-filtered true -O $output4/$fam\_$t[0]_$t[1]_$t[2].Z.DP.GQ.vcf.gz && \\\nbcftools stats $output4/$fam\_$t[0]_$t[1]_$t[2].Z.DP.GQ.vcf.gz > $output4/$fam\_$t[0]_$t[1]_$t[2].Z.DP.GQ.vcf.gz.stat.txt\n\n";
    #chrW
    print SH4 "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" SelectVariants -V $output2/$fam\_$t[0]_$t[1]_$t[2].W.DP.vcf.gz -select 'vc.getGenotype(\"$t[2]\").getGQ() >=$cutGQ && vc.getGenotype(\"$t[0]\").getGQ() >=$cutGQ' --exclude-filtered true -O $output4/$fam\_$t[0]_$t[1]_$t[2].W.DP.GQ.vcf.gz && \\\nbcftools stats $output4/$fam\_$t[0]_$t[1]_$t[2].W.DP.GQ.vcf.gz > $output4/$fam\_$t[0]_$t[1]_$t[2].W.DP.GQ.vcf.gz.stat.txt\n\n";

    #chrZ
    print SH5 "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" SelectVariants -V $output4/$fam\_$t[0]_$t[1]_$t[2].Z.DP.GQ.vcf.gz -select 'vc.getGenotype(\"$t[1]\").getAD().1 == 0.0 && vc.getGenotype(\"$t[0]\").getAD().0 == 0.0' --exclude-filtered true -O $output5/$fam\_$t[0]_$t[1]_$t[2].Z.DP.GQ.AD.vcf.gz && \\\nbcftools stats $output5/$fam\_$t[0]_$t[1]_$t[2].Z.DP.GQ.AD.vcf.gz > $output5/$fam\_$t[0]_$t[1]_$t[2].Z.DP.GQ.AD.vcf.gz.stat.txt\n\n";
    #chrW
    print SH5 "gatk --spark-runner LOCAL --java-options \"-Djava.io.tmpdir=\${pathTMP}\" SelectVariants -V $output4/$fam\_$t[0]_$t[1]_$t[2].W.DP.GQ.vcf.gz -select 'vc.getGenotype(\"$t[2]\").getAD().1 == 0.0 && vc.getGenotype(\"$t[0]\").getAD().0 == 0.0' --exclude-filtered true -O $output5/$fam\_$t[0]_$t[1]_$t[2].W.DP.GQ.AD.vcf.gz && \\\nbcftools stats $output5/$fam\_$t[0]_$t[1]_$t[2].W.DP.GQ.AD.vcf.gz > $output5/$fam\_$t[0]_$t[1]_$t[2].W.DP.GQ.AD.vcf.gz.stat.txt\n\n";
}

print SH1 "echo \"Finish step1.\"\n";
print SH2 "echo \"Finish step2.\"\n";
print SH4 "echo \"Finish step3.\"\n";
print SH5 "echo \"Finish step4.\"\n";

close SH1;
close SH2;
close SH4;
close SH5;

