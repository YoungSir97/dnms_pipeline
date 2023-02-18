#!/usr/bin/env perl
=head1 Usage
    perl callable_genome_by_gvcf.pl <gvcf1> <gvcf2> <child_gvcf>
        --DPmin     for child
        --DPmax     for child
        --GQ        for child
=cut
use strict;
use Getopt::Long;
my ($help,$DPmin,$DPmax,$GQ);
GetOptions(
    "DPmin:i"=>\$DPmin,
    "DPmax:i"=>\$DPmax,
    "GQ:i"=>\$GQ,
    "help!"=>\$help
);
die `pod2text $0` if (@ARGV<1);
$DPmin ||= 25;
$DPmax ||= 100;
$GQ ||= 40;
my $mgvcf=shift;
my $fgvcf=shift;
my $cgvcf=shift;

my $GC = 0;
my $GC_chrZ = 0;
my $GC_chrW = 0;
my $GC_chrMT = 0;

## read gvcf1
my %G;
if ($mgvcf =~ /.gz$/){
    open IN,"gunzip -c $mgvcf | ";
}else{
    open IN,$mgvcf || die "can't open $mgvcf\n";
}
while (<IN>){
    chomp;
    /^#/ && next;
    my @line = split;
    my $k = "$line[0]_$line[1]";
    $G{$k} = 1;
}
close IN;

### read gvcf2
if ($fgvcf =~ /.gz$/){
    open IN,"gunzip -c $fgvcf | ";
}else{
    open IN,$fgvcf || die "can't open $fgvcf\n";
}   
while (<IN>){
    chomp;
    /^#/ && next;
    my @line = split;
    my $k = "$line[0]_$line[1]";
    if ($G{$k}){
        $G{$k} = 2;
    
    }
}
close IN;

### read child gvcf
if ($cgvcf =~ /.gz$/){
    open IN,"gunzip -c $cgvcf | ";
}else{
    open IN,$cgvcf || die "can't open $cgvcf\n";
}
while (<IN>){
    chomp;
    /^#/ && next;
    my @line = split;
    my $k = "$line[0]_$line[1]";
    if ($G{$k}){
        next if ($G{$k} == 1);
        my @info = split /:/,$line[-1];
        if ($info[2] >= $DPmin &&  $info[2] <= $DPmax && $info[3] >= $GQ){
            $GC++;
            if ($line[0] eq 'chrZ'){
                $GC_chrZ++;
            }elsif($line[0] eq 'chrW'){
                $GC_chrW++;
            }elsif($line[0] eq 'chrMT'){
                $GC_chrMT++;
            }
        }
    }
}
close IN;

### output
my $GC_final = $GC - $GC_chrZ - $GC_chrW - $GC_chrMT;
print "Final effective GC: $GC_final\n";
print "# GC_all_sites: $GC\tGC_chrZ: $GC_chrZ\tGC_chrW: $GC_chrW\tGC_chrMT: $GC_chrMT\n";


