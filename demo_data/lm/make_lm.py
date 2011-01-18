########
##
## Make a LM from any text using word-based relative frequencies 
##
#######

from __future__ import division
import sys
import codecs
import re
from collections import defaultdict

file_in=codecs.open(sys.argv[1],'r','utf-8')
file_out=codecs.open(sys.argv[1]+".wordModel",'w','utf-8')

counts=defaultdict(int)

total_counts=0

line=file_in.readline()

while line:
    if(len(line)>1):
        words=line.strip("\n").split(" ")
	for word in words:
            counts[word.lower()]+=1
	    total_counts+=1
    line=file_in.readline()

for word in counts.keys():
  normfreq=(counts[word]/total_counts)
  file_out.write(word+"\t"+"%.9f" %normfreq+"\n")

print "done generating LM"
