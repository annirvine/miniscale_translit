use strict;
use warnings;


die "Usage: $0 inputJoshuaParamFile outputJoshuaParamFile varName value" if @ARGV != 4;


my $inputFile = shift;
my $outputFile = shift;
my $varName = shift;
my $value = shift;


open IN, $inputFile or die;
open OUT, ">$outputFile" or die;

while(<IN>) {
    if(m/^${varName}=(.*)\s*$/) {
	print OUT "${varName}=$value\n";
    }
    else {
	print OUT;
    }
}


close IN;
close OUT;
