import string
import codecs
import sys

infile=codecs.open(sys.argv[1],'r','utf-8')
outfile=codecs.open(sys.argv[1]+".sym",'w','utf-8')

line=infile.readline()

while line:
    line=line.strip("\n").split("\t")
    if(len(line)>1):
      newline="$"+line[0].lower()+"&\t$"+line[1].lower()+"&\n"
    else:
      newline="$"+line[0].lower()+"&\n"
    outfile.write(newline)
    line=infile.readline()
