#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-d outputdir] [-p ncore] <single|paired> <output prefix> <fastq> <Ddir> <Ensembl|UCSC> <build> <--strandedness [none|forward|reverse]>" 1>&2
    echo "Example: star.sh single HeLa_rep1 HeLa_rep1.fastq.gz /work/Database Ensembl GRCh38 reverse" 1>&2
}

odir=star
ncore=12
while getopts d: option
do
    case ${option} in
        d)
            odir=${OPTARG}
            ;;
        p)
            ncore==${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 7 ]; then
  usage
  exit 1
fi

readtype=$1
prefix=$2
fastq=$3
Ddir=$4
db=$5
build=$6
strand=$7

pwd=$(cd $(dirname $0) && pwd)

mkdir -p log $odir

if test $build = "S_pombe" -o $build = "S_cerevisiae"; then
    index_star=$Ddir/$build
    index_rsem=$Ddir/$build/$build
else
    index_star=$Ddir/$db-$build
    index_rsem=$Ddir/$db-$build/$build
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

ex(){ echo $1; eval $1; }

ex "STAR --genomeLoad NoSharedMemory --outSAMtype BAM SortedByCoordinate \
     --quantMode TranscriptomeSAM \
     --runThreadN $ncore --outSAMattributes All $pzip \
     --genomeDir $index_star --readFilesIn $fastq $parstr \
     --outFileNamePrefix $odir/$prefix.$build."

log=log/star-$prefix.$build.txt
echo -en "$prefix\t" > $log
ex "parse_starlog.pl $odir/$prefix.$build.Log.final.out >> $log"

ex "rsem-calculate-expression $pair --alignments --estimate-rspd -p $ncore \
                          --strandedness $strand \
                          --no-bam-output \
                          $odir/${prefix}.$build.Aligned.toTranscriptome.out.bam \
                          $index_rsem \
                          $odir/$prefix.$build"

#ex "rsem-plot-transcript-wiggles --gene-list --show-unique $odir/${prefix}.$build gene_ids.txt output.pdf"
ex "rsem-plot-model $odir/$prefix.$build $odir/$prefix.$build.quals.pdf"
