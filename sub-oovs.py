import codecs
import sys
from collections import defaultdict

####
# Usage:
# python sub-oovs.py tab-separated-oov-dictionary translation-output-file
####



oovsLookup=defaultdict(str)

oovsFile=codecs.open(sys.argv[1],'r','utf-8')
line=oovsFile.readline()
while line:
    line=line.strip().split("\t")
    oovsLookup[line[0]]=line[1]
    line=oovsFile.readline()

translationsFile=codecs.open(sys.argv[2],'r','utf-8')
outputFile=codecs.open(sys.argv[2]+".plustranslit",'w','utf-8')

line=translationsFile.readline()
while line:
    line=line.strip()
    newline=[]
    for word in line.split(" "):
        if word.endswith("OOV"):
            word=word.split("_")
            lookupword=oovsLookup[word[0]]
            newline.append(lookupword)
        else:
            newline.append(word)
    outputFile.write(" ".join(newline)+"\n")
    line=translationsFile.readline()
