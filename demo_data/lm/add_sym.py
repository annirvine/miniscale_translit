import codecs
import sys

infile=codecs.open(sys.argv[1],'r','utf-8')
outfile=codecs.open(sys.argv[1]+'.sym','w','utf-8')

line=infile.readline()

while line:
    line=line.split("\t")
    word='$'+line[0].lower()+'&'
    outfile.write(word+"\t"+line[1])
    line=infile.readline()
