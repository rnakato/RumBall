#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <build> <outprefix>" 1>&2
    echo "  Example:" 1>&2
    echo "  $cmdname GRCh38 $(pwd)/Ensembl-GRCh38" 1>&2
}

while getopts a option
do
    case ${option} in
	a)
	    all=1
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

build=$1
outprefix=$2

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

genome="/opt/Database/$build/genome.fa.gz"
gtf=`ls /opt/Database/$build/*gtf.gz`

ex(){
    echo $1
    eval $1
}

ex "mkdir -p $outprefix"
ex "unpigz -c $genome > $outprefix/genome.fa"
ex "unpigz -c $gtf > $outprefix/chr.gtf"
ex "rsem-prepare-reference --star -p 24 --gtf $outprefix/chr.gtf $outprefix/genome.fa $outprefix/$build"
