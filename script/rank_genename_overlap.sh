#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <file1> <file2> <max_number>" 1>&2
}

if [ $# -ne 3 ]; then
  usage
  exit 1
fi

file1=$1
file2=$2
max=$3

tmpfile1=$(mktemp)
tmpfile2=$(mktemp)

i_max=$(($max/100))

for i in $(seq 1 $i_max)
do
    n=${i}00
    head -n $n $file1 > $tmpfile1
    head -n $n $file2 > $tmpfile2
    count_genename_overlap.sh $tmpfile1 $tmpfile2
done

rm $tmpfile1 $tmpfile2
