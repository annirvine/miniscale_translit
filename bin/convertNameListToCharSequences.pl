use strict;
use warnings;


die "Usage: $0 namesFile charSequencesOutputFile" if @ARGV != 2;

my $inputFile  = shift;
my $outputFile = shift;

open IN, $inputFile or die;
open OUT, ">$outputFile" or die;

binmode IN, ":utf8";
binmode OUT, ":utf8";

while(<IN>) {
    s/\s+$//;
    s/^\s+//;
    die "Error: multi-word name found." if m/\s/;
    die "Error: empty name found" if m/^$/;
    $_ = lc $_;
    my @chars = split //, $_;
    print OUT join(" ", @chars)."\n";    
}

close IN;
close OUT;
