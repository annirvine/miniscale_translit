#!/bin/csh

set testWords = $1
set mainDir = $2
set trainingDir = $mainDir/trained
set testExptDir = $mainDir/tested
set answerWords = $testWords.answer

tcsh test_helper.sh $testWords $trainingDir $testExptDir $answerWords
if $status exit $status

cp $testExptDir/output/output.words temp
python bin/stripoutput.py temp
mv temp.clean $answerWords
rm temp
