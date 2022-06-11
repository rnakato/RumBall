#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <single|paired> <prefix> <fastq> <Ddir> <strandedness>" 1>&2
    echo '   <single|paired>: single-end or paired-end reads' 1>&2
    echo '   <prefix>: prefix of output files' 1>&2
    echo '   <fastq>: fastq files (should be quoted if paired-end)' 1>&2
    echo '   <Ddir>: directory of index and gtf files' 1>&2
    echo '   <strandedness [none|forward|reverse]>: strandedness of input fastq files ("reverse" in the most cases)' 1>&2
    echo '   Options:' 1>&2
    echo '      -d outputdir: Output directory (default: "star/")' 1>&2
    echo '      -p ncore: number of CPUs (default: 12, note that large number (e.g., 64) may cause an error in STAR)' 1>&2
    echo "   Example:" 1>&2
    echo "      $cmdname single HeLa_rep1 HeLa_rep1.fastq.gz Ensembl-GRCh38 reverse" 1>&2
    echo "      $cmdname paired HeLa_rep1 \"HeLa_rep1_1.fastq.gz HeLa_rep1_2.fastq.gz\" Ensembl-GRCh38 reverse" 1>&2
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
