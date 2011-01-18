#!/bin/csh

#set JOSHUA="/home/hltcoe/airvine/Code/joshua"
#set JAVA_HOME="/usr/java/default/"
#set SRILM="/home/hltcoe/airvine/Code/srilm"

if ($#argv != 4) then
    echo "Usage: $0 trainingPairsFile devTestPairsFile wordModelFile trainingRootDir"
    exit 1
endif


# Training files
set trainingPairsFile  = $1
set devTestPairsFile   = $2
set wordModelFile      = $3
set trainingRoot       = $4


# Simple alias for error checking
alias checkError 'if($status) exit $status'

# Binaries
set zmertJarFile                    = bin/zmert_WER.jar
set rerankTransliterationsScript    = bin/rerankWithWordModel.pl
set copyOutputOfBestIterationScript = bin/copyOutputOfBestIteration.pl
set convertNamePairsScript          = bin/convertTabSeparatedNamePairsToCharSequences.pl
#set extractCharLMTrainingScript     = bin/extractCharLMTraining.pl
set extractCharLMTrainingScript     = bin/extract.pl
set replaceVariablesInTemplate      = bin/replaceVariablesInTemplate.pl


#### Create output directory

rm -rf $trainingRoot
mkdir $trainingRoot


#### Align characters

rm -rf $trainingRoot/align
mkdir $trainingRoot/align
mkdir $trainingRoot/align/test
mkdir $trainingRoot/align/train

touch $trainingRoot/align/test/test.e
touch $trainingRoot/align/test/test.f

set sourceTrainingFile = $trainingRoot/align/train/training.f
set targetTrainingFile = $trainingRoot/align/train/training.e
perl $convertNamePairsScript $trainingPairsFile $sourceTrainingFile $targetTrainingFile

perl $replaceVariablesInTemplate config/align.conf $trainingRoot/align/align.conf TRAINING_ROOT_DIR $trainingRoot
./bin/alignScript $trainingRoot/align/align.conf
checkError



#### Train LM
# Create directory
rm -rf $trainingRoot/lm
mkdir $trainingRoot/lm

# Create Char LM training set
set charLMTrainingFile = $trainingRoot/lm/charLMTraining
perl $extractCharLMTrainingScript $wordModelFile $charLMTrainingFile 5000000

checkError

# Train Char LM
$SRILM/bin/i686-m64/ngram-count \
#$SRILM/bin/macosx/ngram-count \
    -order 10 \
    -unk \
    -wbdiscount1 -wbdiscount2 -wbdiscount3 -wbdiscount4 -wbdiscount5 \
    -text $charLMTrainingFile \
    -lm $trainingRoot/lm/translit_charlm
checkError



#### Compile Joshua alignments
rm -rf $trainingRoot/compiledAlign
mkdir $trainingRoot/compiledAlign

#java -Xss4096k -Xmx15g -d64 -cp $JOSHUA/bin/ joshua.corpus.suffix_array.Compile $sourceTrainingFile $targetTrainingFile $trainingRoot/align/output/training.e-f.align $trainingRoot/compiledAlign
java -Xmx1g -d64 -cp $JOSHUA/bin/ joshua.corpus.suffix_array.Compile $sourceTrainingFile $targetTrainingFile $trainingRoot/align/output/training.e-f.align $trainingRoot/compiledAlign
checkError


###################### Run devTest ###############################
#### Create links so devtest files are in expected location
rm -rf $trainingRoot/devTestData
mkdir $trainingRoot/devTestData

set devTestSourceFile = $trainingRoot/devTestData/devTest.f
set devTestTargetFile = $trainingRoot/devTestData/devTest.e

perl $convertNamePairsScript $devTestPairsFile $devTestSourceFile $devTestTargetFile


#### Train devtest grammar
rm -rf $trainingRoot/devModel
mkdir $trainingRoot/devModel

#nohup java -Dfile.encoding=UTF8 -Xmx8g -d64 -cp $JOSHUA/bin \


nohup java -Dfile.encoding=UTF8 -Xmx1g -cp $JOSHUA/bin \
    joshua.prefix_tree.ExtractRules \
    $trainingRoot/compiledAlign \
    $trainingRoot/devModel/dev.grammar.raw \
    $devTestSourceFile
checkError

#nohup java -Dfile.encoding=UTF8 -cp $JOSHUA/bin \
#    joshua.prefix_tree.ExtractRules \
#     --binary-source --binary-target \
#     --source=$trainingRoot/compiledAlign/source.corpus \
#     --target=$trainingRoot/compiledAlign/target.corpus \
#     --source-vocab=$trainingRoot/compiledAlign/common.vocab \
#     --target-vocab=$trainingRoot/compiledAlign/common.vocab \
#     --source-suffixes=$trainingRoot/compiledAlign/source.suffixes \
#     --target-suffixes=$trainingRoot/compiledAlign/target.suffixes \
#     --alignments=$trainingRoot/compiledAlign/alignment.grids \
#     --alignmentsType=MemoryMappedAlignmentGrids \
#     --maxPhraseLength=10 \
#     --maxNonterminals=0 \
#     --test=$devTestSourceFile \
#    --output=$trainingRoot/devModel/dev.grammar.raw
#checkError

###
sort -u $trainingRoot/devModel/dev.grammar.raw -o $trainingRoot/devModel/dev.grammar
checkError

#### Run MERT on decoder
rm -rf $trainingRoot/mert
mkdir $trainingRoot/mert

perl $replaceVariablesInTemplate config/mert_decoder/joshua.config $trainingRoot/mert/joshua.config TRAINING_ROOT_DIR $trainingRoot; checkError
perl $replaceVariablesInTemplate config/mert_decoder/mert.config   $trainingRoot/mert/mert.config   TRAINING_ROOT_DIR $trainingRoot; checkError
perl $replaceVariablesInTemplate config/mert_decoder/mert_decoder_command $trainingRoot/mert/mert_decoder_command TRAINING_ROOT_DIR $trainingRoot; checkError

chmod +x $trainingRoot/mert/mert_decoder_command

java -d64 -Xmx5g -cp $zmertJarFile ZMERT \
    $trainingRoot/mert/mert.config 
checkError


#### Run MERT on reranker


# Create link to word model
#rm -rf $trainingRoot/wordModel
#mkdir $trainingRoot/wordModel
#ln -s $wordModelFile $trainingRoot/wordModel/wordModel

# Create directory for mert of reranking
#rm -rf $trainingRoot/mert_reranker
#mkdir $trainingRoot/mert_reranker

# Copy config and command files to mert reranking output dir
#perl $replaceVariablesInTemplate config/mert_reranker/reranker.config $trainingRoot/mert_reranker/reranker.config \
#    TRAINING_ROOT_DIR $trainingRoot; checkError

#perl $replaceVariablesInTemplate config/mert_reranker/mert.config $trainingRoot/mert_reranker/mert.config \
#    TRAINING_ROOT_DIR $trainingRoot; checkError

#perl $replaceVariablesInTemplate config/mert_reranker/mert_reranker_command $trainingRoot/mert_reranker/mert_reranker_command \
#    TRAINING_ROOT_DIR $trainingRoot RERANK_TRANSLITERATIONS $rerankTransliterationsScript; checkError

#chmod +x $trainingRoot/mert_reranker/mert_reranker_command

#perl $copyOutputOfBestIterationScript $trainingRoot/mert/test.output.nbest.ZMERT.it $trainingRoot/mert_reranker/test.decoder_output.nbest
#checkError



# Run MERT
#java -d64 -Xmx5g -cp $zmertJarFile ZMERT \
#    $trainingRoot/mert_reranker/mert.config 
#checkError
