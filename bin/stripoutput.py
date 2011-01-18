import codecs
import sys

infile=codecs.open(sys.argv[1],'r','utf-8')
outfile=codecs.open(sys.argv[1]+".clean",'w','utf-8')

line=infile.readline()

while line:
    line=line.strip().strip("&").strip("$")
    outfile.write(line+"\n")
    line=infile.readline()
