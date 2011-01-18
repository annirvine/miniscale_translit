use strict;
use warnings;



die "Usage: $0 namePairsFile sourceCharSequences targetCharSequences" if @ARGV != 3;


my $namePairsFile = shift;
my $sourceCharSequencesFile = shift;
my $targetCharSequencesFile = shift;

open IN, $namePairsFile or die "Cannot open file: $namePairsFile";
open SOUT, ">$sourceCharSequencesFile" or die "Cannot open file: $sourceCharSequencesFile";
open TOUT, ">$targetCharSequencesFile" or die "Cannot open file: $targetCharSequencesFile";

binmode IN, ":utf8";
binmode SOUT, ":utf8";
binmode TOUT, ":utf8";


while(<IN>) {
    s/^\s+//;
    s/\s+$//;

    $_ = lc $_;

    my @names = split /\t/;
    die "Unexpected number '".scalar(@names)."'of names seen: $_" if @names != 2;

    my ($sourceName, $targetName) = @names;
    
    $sourceName =~ s/^\s+//;
    $sourceName =~ s/\s+$//;

    $targetName =~ s/^\s+//;
    $targetName =~ s/\s+$//;

    my @sourceTokens = split /\s+/, $sourceName;
    my @targetTokens = split /\s+/, $targetName;

    if(scalar(@sourceTokens) == scalar(@targetTokens)) {
	for(my $i=0; $i<@sourceTokens; $i++) {
	    my $sourceToken = $sourceTokens[$i];
	    print SOUT join(" ", (split //, $sourceToken))."\n";
	}
	for(my $i=0; $i<@targetTokens; $i++) {
	    my $targetToken = $targetTokens[$i];
	    print TOUT join(" ", (split //, $targetToken))."\n";
	}
    }
    else {
	warn "Number of source/target tokens don't match. Skipping line: $_";
    }
}


close IN;
close SOUT;
close TOUT;
