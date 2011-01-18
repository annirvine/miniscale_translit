#!/bin/csh

#set JAVA_HOME="/usr/java/default/"
#set JOSHUA="/home/hltcoe/airvine/Code/joshua"
#set SRILM="/home/hltcoe/airvine/Code/srilm"

if ($#argv != 4) then
    echo "Usage: $0 testSourceNames trainingDir exptDir answerNames"
    exit 1
endif


set testSourceFile  = $1
set trainingRootDir = $2
set exptDir         = $3
set testTargetFile = $4


# Alias for error checking
alias checkError 'if($status) exit $status'

# Binaries
set rerankWithWordModel = bin/rerankWithWordModel.pl
set convertNameListToCharSequences = bin/convertNameListToCharSequences.pl
set replaceJoshuaParam = bin/replaceJoshuaParam.pl

#### Create output directory
mkdir -p $exptDir


###################### Run test ###############################
#### Create links so devtest files are in expected location
rm -rf $exptDir/data
mkdir $exptDir/data

perl $convertNameListToCharSequences $testSourceFile $exptDir/data/test.f
perl $convertNameListToCharSequences $testTargetFile $exptDir/data/test.e


#### Train test grammar
rm -rf $exptDir/model
mkdir $exptDir/model

nohup java -Dfile.encoding=UTF8 -Xmx1g -cp $JOSHUA/bin \
    joshua.prefix_tree.ExtractRules \
    $trainingRootDir/compiledAlign \
    $exptDir/model/test.grammar.raw \
    $exptDir/data/test.f
checkError

#nohup java -Dfile.encoding=UTF8 -Xmx1g -cp $JOSHUA/bin \
#    joshua.prefix_tree.ExtractRules \
#     --binary-source --binary-target \
#     --source=$trainingRootDir/compiledAlign/source.corpus \
#     --target=$trainingRootDir/compiledAlign/target.corpus \
#     --source-vocab=$trainingRootDir/compiledAlign/common.vocab \
#     --target-vocab=$trainingRootDir/compiledAlign/common.vocab \
#     --source-suffixes=$trainingRootDir/compiledAlign/source.suffixes \
#     --target-suffixes=$trainingRootDir/compiledAlign/target.suffixes \
#     --alignments=$trainingRootDir/compiledAlign/alignment.grids \
#     --alignmentsType=MemoryMappedAlignmentGrids \
#     --maxPhraseLength=10 \
#     --maxNonterminals=0 \
#     --test=$exptDir/data/test.f \
#    --output=$exptDir/model/test.grammar.raw
#checkError

sort -u $exptDir/model/test.grammar.raw -o $exptDir/model/test.grammar
checkError


#### Run test
rm -rf $exptDir/output
mkdir $exptDir/output
perl $replaceJoshuaParam $trainingRootDir/mert/joshua.config.ZMERT.final $exptDir/output/joshua.config \
    tm_file $exptDir/model/test.grammar
checkError

java -Xmx1g -cp $JOSHUA/bin/ -Djava.library.path=$JOSHUA/lib -Dfile.encoding=utf8 \
    joshua.decoder.JoshuaDecoder \
    $exptDir/output/joshua.config \
    $exptDir/data/test.f \
    $exptDir/output/decoder.output.nbest
checkError


#### Rerank decoder output
#### Uncomment the following 4 lines to run runranker, and then extract 1-best from reranker.output.nbest instead of decoder.output.nbest
##cp $trainingRootDir/mert_reranker/reranker.config.ZMERT.final $exptDir/output/reranker.config
##checkError

##perl $rerankWithWordModel $exptDir/output/reranker.config $exptDir/output/decoder.output.nbest $exptDir/output/reranker.output.nbest
##checkError

#### Extract 1-best candidate

java -cp $JOSHUA/bin -Dfile.encoding=utf8 \
    joshua.util.ExtractTopCand \
    $exptDir/output/decoder.output.nbest \
    $exptDir/output/decoder.output.1best
checkError


#### Render 1-best candidates as words (glue the separated characters together).

cat $exptDir/output/decoder.output.1best | perl -ne 's/\s+//g; print "$_\n"' > $exptDir/output/output.words
checkError

echo ""
echo "Output for the test source file\n    $testSourceFile\nis available at\n    $exptDir/output/output.words"
