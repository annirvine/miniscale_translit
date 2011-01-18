#!/usr/bin/perl
use strict;
use warnings;


die "Usage: $0 config decoderOutputFile rerankerOutputFile" if @ARGV != 3;

my $configFile = shift;
my $inputFile = shift;
my $outputFile = shift;


my %params = readParams($configFile);
my %wordModel = %{readWordModel(getValue(\%params, "word_model_file"))};
my @scoreNames = split /\s+/, getValue(\%params, "joshua_score_names");

my %sourceId2Hyps = ();


open IN, $inputFile or die "Could not open file $inputFile from directory `pwd`";
open OUT, ">$outputFile" or die "Could not open file $outputFile from directory `pwd`";

while(<IN>) {
    my @tokens = split /\|\|\|/, $_;
    die if @tokens != 4;
    
    
    @tokens = map {s/^\s+//; s/\s+$//; $_;} @tokens;
    my ($sourceId, $outputString, $featureValsString, $summedScore) = @tokens;

    $sourceId2Hyps{$sourceId} = [] if !defined($sourceId2Hyps{$sourceId});
    
    my $outputWord = $outputString;
    $outputWord =~ s/\s+//g;
    my $wordModelProb = getWordModelProb(\%wordModel, $outputWord);
    
    my @featureVals = split /\s+/, $featureValsString;
    push @featureVals, $wordModelProb;

    my $outputSummedScore = getSummedScore(\%params, \@scoreNames, \@featureVals);

    push @{$sourceId2Hyps{$sourceId}}, [$outputString, join(" ", @featureVals), $outputSummedScore];
}

foreach my $sourceId (sort {$a <=> $b} keys %sourceId2Hyps) {
    foreach my $hyp (@{$sourceId2Hyps{$sourceId}}) {
	my ($outputString, $featureValsString, $summedScore) = @$hyp;
	printf(OUT "%s ||| %s ||| %s ||| %s\n", $sourceId, $outputString, $featureValsString, $summedScore);
    }
}

close IN;
close OUT;


sub getSummedScore {
    my ($name2Weight, $names, $vals) = @_;
    my $sum = 0;
    for(my $index=0; $index<@$names; $index++) {
	my $name = $names->[$index];
	my $val  = $vals->[$index];
	my $weight = $name2Weight->{$name};
	$sum += ($weight * $val);
    }
    return $sum;
}

sub getWordModelProb {
    my ($wordModel, $word) = @_;
    if(defined($wordModel->{$word})) {
	return $wordModel->{$word};
    }
    else {
	return 0.0;
    }
}

sub getValue {
    my ($params, $name) = @_;
   
    if(defined($params->{$name})) {
	return $params->{$name};
    }
    else {
	die "Could not find param: $name";
    }
}
	     

sub readWordModel {
    my ($file) = @_;
    open W, $file or die;
    my %words = ();
    while(<W>) {
	s/\s+$//;
	s/^\s+//;
	my @tokens = split /\s+/;
	die if @tokens != 2;
	my ($word, $prob) = @tokens;
	die if defined($words{$word});
	$words{$word} = $prob;
    }
    close W;
    return \%words;
}

sub readParams {
    my ($file) = @_;

    my %params = ();
    open CONFIG, $file or die;
    while(<CONFIG>) {
	next if m/^\s*$/; # skip empty line
	next if m/\s*\#/; # skip comment
	s/\s+$//;
	s/^\s+//;

	my @tokens = split /\s+/, $_, 2;

	die if @tokens<2;
	my ($key, $value) = @tokens;

	#die if @tokens<2;
	#my $value = shift @tokens;
	#my $key = join(" ", @tokens);

	#print "Param read:  $key ===== $value\n";

	die if defined($params{$key});
	$params{$key} = $value;
    }
    close CONFIG;
    return %params;
}
