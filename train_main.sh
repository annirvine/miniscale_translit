#!/bin/csh

set directory = $1

set lmdirectory = demo_data/lm

set trainingPairs = $directory/train
set devPairs      = $directory/dev
set wordModel = $lmdirectory/wiki.english.wordModel.sym
set trainingDir   = $directory/trained

echo $trainingDir
rm -rf $trainingDir
mkdir $trainingDir

tcsh train_helper.sh $trainingPairs $devPairs $wordModel $trainingDir 
if $status exit $status
