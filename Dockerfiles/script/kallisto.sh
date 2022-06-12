#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <prefix> <fastq> <Ddir> <strandedness>" 1>&2
    echo '   <prefix>: prefix of output files' 1>&2
    echo '   <fastq>: paired-end fastq files (should be quoted)' 1>&2
    echo '   <Ddir>: directory of index and gtf files' 1>&2
    echo '   <strandedness [none|forward|reverse]>: strandedness of input fastq files ("reverse" in the most cases)' 1>&2
    echo '   Options:' 1>&2
    echo '      -d outputdir: Output directory (default: "kallisto/")' 1>&2
    echo '      -p ncore: number of CPUs (default: 12, note that large number (e.g., 64) may cause an error in STAR)' 1>&2
    echo "   Example:" 1>&2
    echo "      $cmdname HeLa_rep1 \"HeLa_rep1_1.fastq.gz HeLa_rep1_2.fastq.gz\" Ensembl-GRCh38 reverse" 1>&2
}

odir=kallisto
ncore=12
while getopts d:p: option
do
    case ${option} in
        d) odir=${OPTARG};;
        p) ncore=${OPTARG};;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 4 ]; then
  usage
  exit 1
fi

prefix=$1
fastq=$2
Ddir=$3
strand=$4

if test $strand = "forward"; then
    strand="--fr-stranded"
elif test $strand = "reverse"; then
    strand="--rf-stranded"
else
    strand=""
fi

ex(){ echo $1; eval $1; }

ex "mkdir -p $odir/log"
log=$odir/log/$prefix.txt

index=$Ddir/kallisto-indexes/genome
ex " kallisto quant -i $index $strand -t $ncore -b 100 -o $odir/$prefix $fastq > $log"
