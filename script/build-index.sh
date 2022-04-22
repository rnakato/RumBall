#!/bin/bash
cmdname=`basename $0`
pwd=`pwd`
function usage()
{
    echo "$cmdname [-p ncore] <program> <build> <outprefix>" 1>&2
    echo "  program: data, rsem-star, rsem-bowtie2, hisat2, kallisto, salmon" 1>&2
    echo "  build: GRCh38, GRCh37, GRCm39, GRCm38, BDGP6.32, GRCz11, WBcel235, mRatBN7.2" 1>&2
    echo "  Example:" 1>&2
    echo "  $cmdname rsem-star GRCh38 $pwd/Ensembl-GRCh38" 1>&2
}

ncore=4
while getopts p: option
do
    case ${option} in
	p)
            ncore=${OPTARG}
            ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

program=$1
build=$2
outprefix=$3

if [ $# -ne 3 ]; then
  usage
  exit 1
fi

genome="/opt/Database/$build/genome.fa.gz"
gtf=`ls /opt/Database/$build/*gtf.gz`

ex(){
    echo $1
    eval $1
}

# reference data generation
if test $program = "data"; then
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
# build indexes
elif test $program = "rsem-star"; then
    mkdir -p $outprefix/rsem-star-indexes
    ex "rsem-prepare-reference --star -p $ncore --gtf $outprefix/gtf_chrUCSC/chr.gtf $outprefix/genome.fa $outprefix/rsem-star-indexes/$build"
    STAR --version
elif test $program = "rsem-bowtie2"; then
    mkdir -p $outprefix/rsem-bowtie2-indexes
    ex "rsem-prepare-reference --bowtie2 -p $ncore --gtf $outprefix/gtf_chrUCSC/chr.gtf $outprefix/genome.fa $outprefix/rsem-bowtie2-indexes/$build"
    bowtie2 --version
elif test $program = "salmon" ; then
    mkdir -p $outprefix/salmon-indexes
    ex "salmon index -p $ncore -t $outprefix/genome.fa -i $outprefix/salmon-indexes/$build"
    salmon --version
elif test $program = "kallisto" ; then
    mkdir -p $outprefix/kallisto-indexes
    ex "kallisto index -i $outprefix/kallisto-indexes/$build $outprefix/genome.fa"
    kallisto version
elif test $program = "hisat2"; then
    dir=$outprefix/hisat2-indexes
    mkdir -p $dir
    # genome: HISAT2 index for reference
    # genome_snp: HISAT2 Graph index for reference plus SNPs
    # genome_tran: HISAT2 Graph index for reference plus transcripts
    # genome_snp_tran: HISAT2 Graph index for reference plus SNPs and transcripts
    if test $build = "GRCh38"; then
#	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/grch38_genome.tar.gz  -O $dir/grch38_genome.tar.gz
#	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/grch38_snp.tar.gz     -O $dir/grch38_snp.tar.gz
#	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/grch38_tran.tar.gz    -O $dir/grch38_tran.tar.gz
#	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/grch38_rep.tar.gz     -O $dir/grch38_rep.tar.gz
#	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/grch38_snprep.tar.gz  -O $dir/grch38_snprep.tar.gz
	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/grch38_snptran.tar.gz -O $dir/grch38_snptran.tar.gz
	tar zxvf $dir/grch38_snptran.tar.gz -C $dir
	rm $dir/grch38_snptran.tar.gz
    elif test $build = "GRCh37"; then
	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/grch37_snptran.tar.gz -O $dir/grch37_snptran.tar.gz
	tar zxvf $dir/grch37_snptran.tar.gz -C $dir
	rm $dir/grch37_snptran.tar.gz
    elif test $build = "GRCm38"; then
#	wget --timestamping https://cloud.biohpc.swmed.edu/index.php/s/grcm38/download          -O $dir/grcm38_genome.tar.gz
#	wget --timestamping https://cloud.biohpc.swmed.edu/index.php/s/grcm38_snp/download      -O $dir/grcm38_snp.tar.gz
#	wget --timestamping https://cloud.biohpc.swmed.edu/index.php/s/grcm38_tran/download     -O $dir/grcm38_tran.tar.gz
	wget --timestamping https://cloud.biohpc.swmed.edu/index.php/s/grcm38_snp_tran/download -O $dir/grcm38_snptran.tar.gz
	tar zxvf $dir/grcm38_snptran.tar.gz -C $dir
	rm $dir/grcm38_snptran.tar.gz
    else
	echo "Specify the correct build."
	usage
	exit 1
    fi
else
    echo "Specify the correct program type."
    usage
    exit 1
fi
