#!/usr/bin/env perl
=head1 Usage
    perl reads_stand_check.pl <vcf>
        --ref   reference genome
        --fbam  father's bam
        --mbam  mother's bam
        --outdir
=cut
use strict;
use Cwd 'abs_path';
use Getopt::Long;
use File::Basename;
my ($help,$ref,$fbam,$mbam,$outdir);
GetOptions(
    "outdir:s"=>\$outdir,
    "ref:s"=>\$ref,
    "fbam:s"=>\$fbam,
    "mbam:s"=>\$mbam,
    "help!"=>\$help
);
die `pod2text $0` if (@ARGV<1 || !$ref || !$fbam || !$mbam);
$outdir ||="./";
$outdir = abs_path($outdir);
-e $outdir || mkdir -p $outdir;

my $vcf = shift;
if ($vcf =~ /\.gz$/){
    open IN,"gunzip -c $vcf | " || die "Error! can't open vcf file: $vcf\n";
}else{
    open IN,$vcf || die "Error! can't open vcf file: $vcf\n";
}
my $logname = basename $vcf;
open LF,">$outdir/$logname.f.log";
open LM,">$outdir/$logname.m.log";
while (<IN>){
    chomp;
    if (/^#/){
        print "$_\n";
        next;
    }

    my @a = split;
    my $info1 =`samtools mpileup -f $ref -r $a[0]:$a[1]-$a[1] $fbam`;
    print LF "$info1";
    my $info2 =`samtools mpileup -f $ref -r $a[0]:$a[1]-$a[1] $mbam`;
    print LM "$info2";

    chomp $info1;chomp $info2;
    my @f = split /\s+/,$info1;
    my @m = split /\s+/,$info2;
    my $fn = ($f[4] =~ s/([A-Z])/$1/isg);
    my $mn = ($m[4] =~ s/([A-Z])/$1/isg);

    next if ($fn > 0);
    next if ($mn > 0);
    
    print "$_\n";
}
close LF;
close LM;
close IN;


