#!/usr/bin/env perl
=head1 Usage
    perl VCF_window_ckeck.pl <vcf>
        --window <int>  window size, default=200
        --output <str>  output vcf file path
        --delete <int>  cutoff SNP numbers in each window, default=4
=cut
use strict;
use Cwd 'abs_path';
use Getopt::Long;
my ($help,$window,$delete,$output);
GetOptions(
    "help!"=>\$help,
    "window:i"=>\$window,
    "delete:n"=>\$delete,
    "output:s"=>\$output,
);
die `pod2text $0` if (@ARGV<1);
$window ||= 200;
$output ||="./window$window.ckeck.vcf";

## save input to hash
my $vcf = shift;
my (%V,@header);
if ($vcf =~ /\.gz$/){
    open IN,"gunzip -c $vcf | " || die "Error! can't open vcf file: $vcf\n";
}else{
    open IN,$vcf || die "Error! can't open vcf file: $vcf\n";
}
while (<IN>){
    chomp;
    if (/^#/){
        push (@header,$_);
        next;
    }

    my @a = split;
    $V{$a[0]}{$a[1]} = $_;
}
close IN;

## window statistics
my %D;
foreach my $chr (sort keys %V){
    my @site = sort {$a <=> $b} keys %{$V{$chr}};

    #my $n = 0;
    #my $w_s = $site[0];    #start site of window
    foreach my $i (0..$#site){
        my $n = 0;
        my $w_s = $site[$i];    #start site of window
        my $w_e = $w_s + $window;   # end site of window

        my @info;
        foreach my $s ($i..$#site){
            if ($site[$s] < $w_e){
                $n++;
                push (@info, $V{$chr}{$site[$s]});
            }else{
                last;
            }
        }

        my $win = "$w_s-$w_e";
        $D{$chr}{$win} = $n;
    }
}

## output
if ($delete){
    if ($vcf =~ /\.gz$/){
        open IN,"gunzip -c $vcf | " || die "Error! can't open vcf file: $vcf\n";
    }else{
        open IN,$vcf || die "Error! can't open vcf file: $vcf\n";
    }

    while (<IN>){
        chomp;
        if (/^#/){
            print "$_\n";
            next;
        }

        my @b = split;
        my $mark = 0;

        foreach my $w(sort keys %{$D{$b[0]}}){
            my ($start,$end) = split /-/,$w;
            if ($b[1] >= $start && $b[1] < $end){
                if ($D{$b[0]}{$w} >= $delete){
                    $mark = 1;
                    #print "$b[0]: $start < $b[1] < $end and $D{$b[0]}{$w} >= $delete\n";
                }
            }
        }
        next if ($mark == 1);
        print "$_\n";
    }
    close IN;

}else{
    foreach my $chr(sort keys %V){
        foreach my $w(sort keys %{$D{$chr}}){
            print "$chr\t$w\t$D{$chr}{$w}\n";
        }
    }
}

