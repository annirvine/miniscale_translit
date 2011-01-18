## script updated to take two languages and produce all pairs of two

$filename = $ARGV[0];
$selectedLang = $ARGV[2];
$selectedLangTwo = $ARGV[1];

open(FILE, $filename) or die("Couldn't open $filename\n");
binmode(FILE, ":utf8");
binmode(STDOUT, ":utf8");


$line = <FILE>;
chomp $line;
@langCodes = split(/\t/, $line);
%langIndex = ();
for($i = 0; $i < @langCodes; $i++) {
    $langIndex{$langCodes[$i]} = $i;
}

$indexToPrint = $langIndex{$selectedLang};
$secondIndexToPrint = $langIndex{$selectedLangTwo};


while($line = <FILE>) {
    chomp $line;
    @names = split(/\t/,$line);
    $otherName2 = $names[$secondIndexToPrint];
    #$englishName = $names[0];
    $otherName = $names[$indexToPrint];
    if(!($otherName eq "") && !($otherName2 eq "")) {
	#$englishName =~ s/\s?\(.+\)//g;
	$otherName2=~ s/\s?\(.+\)//g;
	$otherName =~ s/\s?\(.+\)//g;
	print STDOUT "$otherName2\t$otherName\n";
    }
}
close(FILE);

