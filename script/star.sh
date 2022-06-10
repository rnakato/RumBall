#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-d outputdir] [-p ncore] <single|paired> <output prefix> <fastq> <Ddir> <--strandedness [none|forward|reverse]>" 1>&2
    echo "Example: star.sh single HeLa_rep1 HeLa_rep1.fastq.gz /work/Database/Database_fromDocker/Ensembl-GRCh38 reverse" 1>&2
}

odir=star
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

if [ $# -ne 5 ]; then
  usage
  exit 1
fi

readtype=$1
prefix=$2
fastq=$3
Ddir=$4
strand=$5

pwd=$(cd $(dirname $0) && pwd)

index_star=$Ddir/rsem-star-indexes/genome/star/
index_rsem=$Ddir/rsem-star-indexes/genome/rsem/index

if test $readtype = "paired"; then
    pair="--paired-end"
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

ex "mkdir -p $odir/log"

STAR --genomeLoad NoSharedMemory --outSAMtype BAM SortedByCoordinate \
     --quantMode TranscriptomeSAM \
     --runThreadN $ncore --outSAMattributes All $pzip \
     --genomeDir $index_star --readFilesIn $fastq $parstr \
     --outFileNamePrefix $odir/$prefix.

log=$odir/log/star-$prefix.txt
ex "parse_starlog.pl $odir/$prefix.Log.final.out > $log"
ex "rm -rf $odir/$prefix._STARtmp"

ex "rsem-calculate-expression $pair --alignments --estimate-rspd -p $ncore \
                          --strandedness $strand \
                          --no-bam-output \
                          $odir/${prefix}.Aligned.toTranscriptome.out.bam \
                          $index_rsem \
                          $odir/$prefix"

#ex "rsem-plot-transcript-wiggles --gene-list --show-unique $odir/${prefix} gene_ids.txt output.pdf"
ex "rsem-plot-model $odir/$prefix $odir/$prefix.quals.pdf"
