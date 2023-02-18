#!/usr/bin/env perl
=head1 Description
    Count the numbers of SNPs each sample from vcf file
    Author: yangshuai@ioz.ac.cn, 2022-02-07

=head1 Usage

    perl SampleVariantCountStat.pl <vcf>
        --pass          only count the numbers of PASS
        --type <str>    count variant type: "SNP" or "Indel"
=cut
use strict;
#use Cwd 'abs_path';
use Getopt::Long;
my ($help,$pass,$type);
GetOptions(
    "help!"=>\$help,
    "pass"=>\$pass,
    "type:s"=>\$type,
);
die `pod2text $0` if (@ARGV<1);

my $vcf = shift;

if($vcf =~ /\.gz$/){
    open IN,"gunzip -c $vcf | ";
}else{
    open IN,$vcf;
}

my (%S,%N,%C); #sample, numbers, chr
while (<IN>){
    chomp;
    /##/ && next;
    my @a = split;
    if (/^#CHROM/){
        foreach my $i(9..$#a){
            $S{$i} = $a[$i];
        }
        next;
    }
    $C{$a[0]} = 1;

    if ($pass){
        if ($a[6] ne "PASS"){
            next;
        }
    }
    if ($type){
        # type      ref     alt
        # SNP       A       G  A,T  *,C,A
        # Indel     AA      *
        # Indel     A       GG  AA,T  *,C,AA
        $type = uc($type);
        die "Parameter error: --type $type unrecognized, please use \"SNP\" or \"Indel\"\n" if ($type ne "SNP" && $type ne "INDEL");

        if (length $a[3] != 1){
            next if ($type eq "SNP");
        }else{
            if (length $a[4] != 1){
                if ($a[4] !~ /,/){
                    next if ($type eq "SNP");
                }else{
                    my @alt = split /,/,$a[4];
                    my $tmpmark = 1;
                    foreach my $i(@alt){
                        $tmpmark++ if (length $i != 1);
                    }
                    next if ($tmpmark == 1 && $type ne "INDEL");
                    next if ($tmpmark != 1 && $type ne "SNP")
                }
            }else{
                next if ($type eq "INDEL");
            }
        }
    }

    foreach my $i(9..$#a){
        my @b = split /:/,$a[$i];
        if ($b[0] !~ /0.0/ && $b[0] !~ /\.\/\./){        # 0/0  0|0  ./.
            $N{$S{$i}}{$a[0]} += 1;
        }
    }
}
close IN;

# output
print "ID";
foreach my $c (sort keys %C){
    print "\t$c";
}
print "\tTotal\n";

foreach my $i(sort {$a <=> $b} keys %S){
    my $t = 0;
    print "$S{$i}";
    foreach my $c (sort keys %C){
        if ($N{$S{$i}}{$c}){
            print "\t$N{$S{$i}}{$c}";
            $t +=$N{$S{$i}}{$c};
        }else{
            print "\t0";
        }
    }
    print "\t$t\n";
}


