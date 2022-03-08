#!/bin/bash
cmdname=`basename $0`
pwd=`pwd`
function usage()
{
    echo "$cmdname <build> <outprefix>" 1>&2
    echo "  Example:" 1>&2
    echo "  $cmdname GRCh38 $pwd/Ensembl-GRCh38" 1>&2
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

ex "mkdir -p $outprefix/gtf_original $outprefix/gtf_chrUCSC"
ex "unpigz -c $genome > $outprefix/genome.fa"
ex "unpigz -c $gtf > $outprefix/gtf_original/chr.gtf"
ex "convertchr_fromEns2UCSC.pl $outprefix/gtf_original/chr.gtf > $outprefix/gtf_chrUCSC/chr.gtf"

for dir in gtf_original gtf_chrUCSC
do
    ex "extract_proteincoding.pl $outprefix/$dir/chr.gtf > $outprefix/$dir/chr.proteincoding.gtf"
    for head in $outprefix/$dir/chr $outprefix/$dir/chr.proteincoding
    do
        ex "gtf2refFlat -g $head.gtf > $head.transcript.refFlat"
        ex "gtf2refFlat -u -g $head.gtf > $head.gene.refFlat"
        cat $head.gene.refFlat | awk 'BEGIN { OFS="\t" } {if($4=="+") {print $3, $5, $5, $1} else {print $3, $6, $6, $1} }' | uniq | grep -v chrom > $head.gene.TSS.bed
        cat $head.transcript.refFlat | awk 'BEGIN { OFS="\t" } {if($4=="+") {print $3, $5, $5, $14} else {print $3, $6, $6, $14} }' | uniq | grep -v chrom > $head.transcript.TSS.bed
        cat $head.gene.refFlat | awk 'BEGIN { OFS="\t" } {if($4=="+") {print $3, $6, $6, $1} else {print $3, $5, $5, $1} }' | uniq | grep -v chrom > $head.gene.TES.bed
        cat $head.transcript.refFlat | awk 'BEGIN { OFS="\t" } {if($4=="+") {print $3, $5, $5, $14} else {print $3, $5, $5, $14} }' | uniq | grep -v chrom > $head.transcript.TES.bed
    done
done

ex "rsem-prepare-reference --star -p 24 --gtf $outprefix/gtf_chrUCSC/chr.gtf $outprefix/genome.fa $outprefix/$build"
