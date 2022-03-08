#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-d outputdir] <single|paired> <output prefix> <fastq> <Ensembl|UCSC> <build> <--strandedness [none|forward|reverse]>" 1>&2
}

odir=star
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

if [ $# -ne 6 ]; then
  usage
  exit 1
fi

readtype=$1
prefix=$2
fastq=$3
db=$4
build=$5
strand=$6

pwd=$(cd $(dirname $0) && pwd)

mkdir -p log $odir
Ddir=`$pwd/../script_rnakato/database.sh`

if test $build = "S_pombe" -o $build = "S_cerevisiae"; then
    index_star=$Ddir/rsem-star-indexes/$build
    index_rsem=$Ddir/rsem-star-indexes/$build/$build
else
    index_star=$Ddir/rsem-star-indexes/$db-$build
    index_rsem=$Ddir/rsem-star-indexes/$db-$build/$db-$build
fi

if test $readtype = "paired"; then pair="--paired-end"
elif ! test $readtype = "single"; then
    echo "Error: specify [single|paired]"
  usage
  exit 1
fi
if test $strand = "none"; then  # unstraned
    parstr="--outSAMstrandField intronMotif"
    parWig="--outWigStrand Unstranded"
else          # stranded
    parWig="--outWigStrand Stranded"
fi

if [ "`echo $fastq | grep '.gz'`" ] ; then
    pzip="--readFilesCommand zcat"
fi

STARdir=$pwd/../binaries/STAR-2.7.3a/bin/Linux_x86_64_static

$STARdir/STAR --genomeLoad NoSharedMemory --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM \
    --runThreadN 12 --outSAMattributes All $pzip \
    --genomeDir $index_star --readFilesIn $fastq $parstr \
    --outFileNamePrefix $odir/$prefix.$build.

log=log/star-$prefix.$build.txt
echo -en "$prefix\t" > $log
$pwd/parse_starlog.pl $odir/$prefix.$build.Log.final.out >> $log

RSEMdir=$(cd $(dirname $0) && pwd)/../binaries/RSEM-1.3.3/
$RSEMdir/rsem-calculate-expression $pair --alignments --estimate-rspd --strandedness $strand --no-bam-output -p 12 $odir/${prefix}.$build.Aligned.toTranscriptome.out.bam $index_rsem $odir/$prefix.$build

#$RSEMdir/rsem-plot-transcript-wiggles --gene-list --show-unique mmliver_single_quals gene_ids.txt output.pdf
$RSEMdir/rsem-plot-model $odir/$prefix.$build $odir/$prefix.$build.quals.pdf
