#!/bin/bash
cmdname=`basename $0`
pwd=`pwd`
function usage()
{
    echo "$cmdname [-p ncore] <program> <build> <odir>" 1>&2
    echo "  program: rsem-star, rsem-bowtie2, hisat2, kallisto, salmon" 1>&2
    echo "  build (only for hisat2):" 1>&2
    echo "         human (GRCh38, GRCh37)" 1>&2
    echo "         mouse (GRCm39, GRCm38)" 1>&2
    echo "         rat (mRatBN7.2)" 1>&2
    echo "         fly (BDGP6)" 1>&2
    echo "         zebrafish (GRCz11)" 1>&2
    echo "         C. elegans (WBcel235)" 1>&2
    echo "         S. serevisiae (R64-1-1)" 1>&2
    echo "  Example:" 1>&2
    echo "         $cmdname rsem-star GRCh38 Ensembl-GRCh38" 1>&2
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
odir=$3

if [ $# -ne 3 ]; then
  usage
  exit 1
fi

ex(){
    echo $1
    eval $1
}

genome="$odir/genome.fa"
gt="$odir/genometable.txt"
gtf="$odir/gtf_chrUCSC/chr.gtf"
mkdir -p $odir/log
log="$odir/log/build-index.$program.genome.log"

# reference data generation
if test $program = "rsem-star"; then
    indexdir=$odir/rsem-star-indexes/genome
    mkdir -p $indexdir
    STAR --version > $log
    glen=`cat $gt | awk '{sum+=$2} END {print sum}'`
    k=`echo $glen | awk '{printf "%d\n",log($1)/log(2)/2-1}'`
    if test $k -gt 14; then k=14; fi
    ex "STAR --runThreadN $ncore --runMode genomeGenerate --genomeSAindexNbases $k \
        --genomeDir $odir/rsem-star-indexes --genomeFastaFiles $genome --sjdbGTFfile $gtf --sjdbOverhang 100 \
        --outFileNamePrefix $indexdir" >> $log
    ex "rsem-prepare-reference -p $ncore --gtf $gtf $genome $indexdir" >> $log 2>&1
elif test $program = "rsem-bowtie2"; then
    indexdir=$odir/rsem-bowtie2-indexes/genome
    mkdir -p $indexdir
    bowtie2 --version > $log
    ex "rsem-prepare-reference --bowtie2 -p $ncore --gtf $gtf $genome $indexdir" >> $log
elif test $program = "salmon" ; then
    indexdir=$odir/salmon-indexes/genome
    mkdir -p $indexdir
    salmon --version > $log
    ex "salmon index -p $ncore -t $genome -i $indexdir" >> $log
elif test $program = "kallisto" ; then
    indexdir=$odir/kallisto-indexes/genome
    mkdir -p $indexdir
    kallisto version > $log
    ex "kallisto index -i $indexdir $genome" >> $log
elif test $program = "hisat2"; then
    indexdir=$odir/hisat2-indexes
    mkdir -p $indexdir
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
	tar zxvf $indexdir/grch38_snptran.tar.gz -C $indexdir
	rm $indexdir/grch38_snptran.tar.gz
    elif test $build = "GRCh37"; then
	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/grch37_snptran.tar.gz -O $indexdir/grch37_snptran.tar.gz
	tar zxvf $indexdir/grch37_snptran.tar.gz -C $indexdir
	rm $indexdir/grch37_snptran.tar.gz
    elif test $build = "GRCm38"; then
#	wget --timestamping https://cloud.biohpc.swmed.edu/index.php/s/grcm38/download          -O $dir/grcm38_genome.tar.gz
#	wget --timestamping https://cloud.biohpc.swmed.edu/index.php/s/grcm38_snp/download      -O $dir/grcm38_snp.tar.gz
#	wget --timestamping https://cloud.biohpc.swmed.edu/index.php/s/grcm38_tran/download     -O $dir/grcm38_tran.tar.gz
	wget --timestamping https://cloud.biohpc.swmed.edu/index.php/s/grcm38_snp_tran/download -O $indexdir/grcm38_snptran.tar.gz
	tar zxvf $indexdir/grcm38_snptran.tar.gz -C $indexdir
	rm $indexdir/grcm38_snptran.tar.gz
    elif test $build = "BDGP6"; then
	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/bdgp6_tran.tar.gz -O $indexdir/bdgp6_tran.tar.gz
	tar zxvf $indexdir/bdgp6_tran.tar.gz -C $indexdir
	rm $indexdir/bdgp6_tran.tar.gz
    elif test $build = "WBcel235"; then
	wget --timestamping https://genome-idx.s3.amazonaws.com/hisat/wbcel235_tran.tar.gz -O $indexdir/wbcel235_tran.tar.gz
	tar zxvf $indexdir/wbcel235_tran.tar.gz -C $indexdir
	rm $indexdir/wbcel235_tran.tar.gz
    elif test $build = "R64-1-1"; then
	wget --timestamping https://cloud.biohpc.swmed.edu/index.php/s/akeiMrGGtt5KoJY/download -O $indexdir/R64-1-1_tran.tar.gz
	tar zxvf $indexdir/R64-1-1_tran.tar.gz -C $indexdir
	rm $indexdir/R64-1-1_tran.tar.gz
    else
	echo "Specify the correct build for hisat2."
	usage
	exit 1
    fi
else
    echo "Specify the correct program type."
    usage
    exit 1
fi
