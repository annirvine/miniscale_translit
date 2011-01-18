from __future__ import division
import string
import codecs
import re
import sys
sys.path.append("bin")
import stringdiff_plus as sd

####
# Usage:
# python evaluate.py my-answer-file my-ref-file
####

cands=sys.argv[1]
ans=sys.argv[2]

candidates=codecs.open(cands,'r','utf-8')
answers=codecs.open(ans,'r','utf-8')

line_a=answers.readline()
line_c=candidates.readline()

countlines=0

sumdist=0
perfect=0

countwords=0

sumnormdist=0

while line_c:
  cword=line_c.strip("\n").lower().strip("$").strip("&")
  aword=line_a.strip("\n").lower().strip("$").strip("&")
  rules,dist=sd.levenshtein(cword,aword)
  sumnormdist+=dist/len(aword)
  sumdist+=dist
  if dist==0:
    perfect+=1
  countwords+=1
  line_c=candidates.readline()
  line_a=answers.readline()

print 'word pairs read:',countwords
print "perfect transliterations:", perfect
print "percent exactly correct:",(perfect/countwords)*100
print "average distance:", sumdist/countwords
print "average normalized  distance:", sumnormdist/countwords

