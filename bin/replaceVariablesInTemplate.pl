use strict;
use warnings;


die "Usage: $0 templateFile outputFile var1 val1 [var2 val2 var3 val3 ...]" if (@ARGV<4 || scalar(@ARGV)%2 != 0);


my $inputFile  = shift;
my $outputFile = shift;


my @pairs = @ARGV;
my %var2Value = ();

for(my $i=0; $i<@pairs; $i+=2) {
    my $varName = $pairs[$i];
    my $value   = $pairs[$i+1];
    die if defined($var2Value{$varName});
    $var2Value{$varName} = $value;
}


open IN, $inputFile or die;
open OUT, ">$outputFile" or die;

while(<IN>) {
    foreach my $varName(keys %var2Value) {
	my $value = $var2Value{$varName};
	s/\+$varName\+/$value/g; 
    }
    print OUT;
}

close IN;
close OUT;

