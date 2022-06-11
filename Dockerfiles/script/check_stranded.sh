#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <human|mouse> <fastq>" 1>&2
}

while getopts d: option
do
    case ${option} in
        d)
            odir=${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

build=$1
fastq=$2

Ddir=/opt/NCBI
if test $build = "human"; then
    index=$Ddir/NCBI-H_sapiens-allrna.NM
elif test $build = "mouse"; then
    index=$Ddir/NCBI-M_musculus-allrna.NM
else
    echo "Error: specify [human|mouse]"
  usage
  exit 1
fi

if [[ $fastq = *.gz ]]; then
    command="bowtie $index <(zcat $fastq) -p12 | cut -f2 | sort | uniq -c"
else
    command="bowtie $index $fastq -p12 | cut -f2 | sort | uniq -c"
fi

echo $command
eval $command
