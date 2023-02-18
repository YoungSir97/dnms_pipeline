#!/usr/bin/env perl
=head1 Usage
    perl vcf_overlap.pl <vcf1> <vcf2> ...
=cut
use strict;
use Cwd 'abs_path';
use Getopt::Long;
my ($help);
GetOptions(
  "help!"=>\$help
);
die `pod2text $0` if (@ARGV<1);

my %H;
foreach my $in(@ARGV){
    if ($in =~ /\.gz$/){
        open IN,"gunzip -c $in | ";
    }else{
        open IN,$in;
    }
    while (<IN>){
        chomp;
        /^#/ && next;

        my @a = split /\s+/,$_;
        my $site = "$a[0]:$a[1]";
        $H{$site}{$in}=1;
    }
    close IN;
}


foreach my $s(sort keys %H){
    my $num = 0;
    my @tmp;
    foreach my $i(sort keys %{$H{$s}}){
        push @tmp,$i;
        $num++;
    }
    my $info = join ",",@tmp;
    print "$s\t$num\t$info\n";
}


