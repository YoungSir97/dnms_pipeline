#!/usr/bin/env perl
=head1 Usage
    perl CpG2.pl   
=cut
use strict;
use Cwd 'abs_path';
use Getopt::Long;
my ($help);
GetOptions(
    "help!"=>\$help
);
die `pod2text $0` if (@ARGV<1);

my $in =shift;
open IN,$in;
while (<IN>){
    chomp;
    my @a = split;

    if ($a[4] =~ /(\w)->(\w)/){
        my $b = $1;
        my $d = $2;
        if ($b eq "C" && $a[5] eq "G"){
            if ($d eq "T"){
                print "*";
            }
            print "$_\n";
        }elsif ($b eq "G" && $a[3] eq "C"){
            if ($d eq "A"){
                print "*";
            }
            print "$_\n";
        }
    }else{
        warn "check: $_\n";
    }
}
close IN;

