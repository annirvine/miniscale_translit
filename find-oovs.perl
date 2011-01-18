$oovs = {};
while($line = <>) {
    @words = split(/\s+|\)|\(/, $line);
    for $word (@words) {
	if($word =~ m/_OOV/) {
	    ($oov, $marker) = split(/_/, $word);
	    $oovs{$oov}++;
	}
    }
}

for $oov (keys(%oovs)) {
    print $oov . "\n";
}
