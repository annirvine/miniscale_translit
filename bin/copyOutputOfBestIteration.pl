use strict;
use warnings;

die "Usage: $0 inputPrefix outputFile" if @ARGV != 2;

my $inputPrefix = shift;
my $outputFile = shift;


my $index=1;
while(1) {
    my $file = $inputPrefix.$index;
    if(-e $file) {
	$index++;
    }
    else {
	last;
    }
}


if($index==1) {
    die "Didn't find any inputs with prefix: $inputPrefix\n";
}
else {
    $index--;
    my $cmd = "cp -f $inputPrefix$index $outputFile";
    (system($cmd)==0) or die "Command failed: $cmd";
}
