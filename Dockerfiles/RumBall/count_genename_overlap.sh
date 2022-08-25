#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <file1> <file2>" 1>&2
}

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

file1=$1
file2=$2

tmpfile1=$(mktemp)
tmpfile2=$(mktemp)

num1=`cat $file1 | wc -l`
num2=`cat $file2 | wc -l`
cut -f1 $file1 > $tmpfile1
cut -f1 $file2 > $tmpfile2
overlap=`grep -x -f $tmpfile1 $tmpfile2 | wc -l`
#overlap=`combine_lines_from2files.pl -1 $file1 -2 $file2 -a 0 -b 0 | wc -l`

perc1=`echo $overlap $num1 | awk '{printf ("%f",$1/$2)}'`
perc2=`echo $overlap $num2 | awk '{printf ("%f",$1/$2)}'`
echo -e "$num1\t$num2\t$overlap\t$perc1\t$perc2"

rm $tmpfile1 $tmpfile2
