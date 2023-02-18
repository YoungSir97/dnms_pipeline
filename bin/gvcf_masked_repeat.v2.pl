#!/usr/bin/env perl
=head1 Usage
    perl gvcf_masked_repeat.pl <gvcf>
        --bed
        --DPmin
        --DPmax
        --GQ
=cut
use strict;
use Cwd 'abs_path';
use Getopt::Long;
my ($help,$bed,$DPmin,$DPmax,$GQ);
GetOptions(
    "bed:s"=>\$bed,
    "DPmin:i"=>\$DPmin,
    "DPmax:i"=>\$DPmax,
    "GQ:i"=>\$GQ,
    "help!"=>\$help
);
die `pod2text $0` if (@ARGV<1);
my $gvcf = shift;
$DPmin ||= 25;
$DPmax ||= 100;
$GQ ||= 40;
$bed ||= "/home/ubuntu/1.Project/DNMs/02.process.oldgenome/refgenome_3.2.4/Zebrafinch.rename.fa.masked_reapeat.bed";

my %B;
open IN,$bed;
while (<IN>){
    chomp;
    my @a = split;
    for my $i ($a[1]..$a[2]){
        my $k = "$a[0]_$i";
        $B{$k} = 1;
        #print "$i\n";
    }
}
close IN;

if ($gvcf =~ /.gz$/){
    open IN,"gunzip -c $gvcf | ";
}else{
    open IN,$gvcf || die "can't open $gvcf\n";
}
while (<IN>){
    chomp;
    /^#/ && next;
    my @v = split;

    my @info = split /:/,$v[-1];
    if ($info[0] eq '0/0' && $info[2] >= $DPmin &&  $info[2] <= $DPmax && $info[3] >= $GQ){
        my $key = "$v[0]_$v[1]";
        next if ($B{$key});
        print "$_\n";
    }
}
close IN;

