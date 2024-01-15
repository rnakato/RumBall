#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-t] <tsv> <tsv> ..." 1>&2
    echo '   <tsv>: abundance.tsv from kallisto' 1>&2
    echo '   Options:' 1>&2
    echo '      -t : Output TPM (default: estimated count)' 1>&2
}

tpm="no"
while getopts t option
do
    case ${option} in
        t) tpm="yes";;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

# check arguments
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

tmpfile1=$(mktemp)
tmpfile2=$(mktemp)

#cut -f1,2,3 $1 > $tmpfile1
cut -f1 $1 > $tmpfile1

for file in ${@:1}
do
    if test $tpm = "yes"; then
      cut -f5 $file | paste $tmpfile1 - > $tmpfile2
    else
      cut -f4 $file | paste $tmpfile1 - > $tmpfile2
    fi
    mv $tmpfile2 $tmpfile1
done

#echo -en "target_id\tlength\teff_length"
echo -en "target_id"
for file in ${@:1}
do
   echo -en "\t`echo $file | sed -e 's/kallisto\///g' -e 's/\/abundance.tsv//g'`"
done

echo ""
tail -n +2 $tmpfile1 | sed -e 's/\.[0-9]\t/\t/g'
