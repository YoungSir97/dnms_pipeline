#!/usr/bin/env perl
=head1 Usage
    perl CpG.pl <gvcf_list> <dnms_list>
=cut
use strict;
use Cwd 'abs_path';
use Getopt::Long;
my ($help);
GetOptions(
    "help!"=>\$help
);
die `pod2text $0` if (@ARGV<1);

my $gvcf = shift;
my $list = shift;

my %G;
open IN,$gvcf;
while (<IN>){
    chomp;
    my ($id,$file) = (split)[0,1];
    $G{$id} = $file;
}
close IN;


open IN,$list;
while (<IN>){
    chomp;
    my @a = split;
    my $info = `gzip -dc $G{$a[0]} | grep -m 1 -P "^$a[3]\\t$a[4]\\t" -B 1 -A 1`;

    if ($info){
        chomp $info;
        my @lines = split /\n/,$info;
        print "$a[0]\t$a[3]\t$a[4]\t$a[6]\t$a[7]";
        foreach my $line (@lines){
            my @b = split /\s+/,$line;
            my $gt = (split /:/,$b[-1])[0];

            print "\t$b[3] $b[4] $gt";
        }
        print "\n";
    }else{
        warn "no grep a[3]\t$a[4]\n";
    }
}
close IN;


