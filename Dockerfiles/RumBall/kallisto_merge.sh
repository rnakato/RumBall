#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <inputdirs> <prefix> <Ddir>" 1>&2
    echo '   <inputdirs>: directories of samples (should be quoted)' 1>&2
    echo '   <prefix>: prefix of output files' 1>&2
    echo '   <Ddir>: directory of index and gtf files' 1>&2
    echo '   Options:' 1>&2
    echo '      -s <strings for sed>: specify strings that you want to remove from sample labels (e.g., "HeLa_", multiple strings should be separated by spaces)' 1>&2
    echo "   Example:" 1>&2
    echo "      $cmdname \"kallisto/Ctrl1 kallisto/Ctrl2 kallisto/siCTCF1 kallisto/siCTCF2\" Matrix_kallisto/HEK293 $Ddir" 1>&2
}

str_sed=""
while getopts s: option
do
    case ${option} in
        s) str_sed=${OPTARG};;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -lt 3 ]; then
  usage
  exit 1
fi

files=$1
output=$2
Ddir=$3

ex(){ echo $1; eval $1; }

gtf=$Ddir/gtf_chrUCSC/chr.gtf
refFlat_transcript=$Ddir/gtf_chrUCSC/chr.transcript.refFlat
refFlat_gene=$Ddir/gtf_chrUCSC/chr.gene.refFlat

### Transcript level
echo "merging tsv files to $output.transcript.tsv..."
mergekallistotsv.sh -t $files > $output.transcript.TPM.tsv
mergekallistotsv.sh    $files > $output.transcript.count.tsv

for norm in TPM count
do
    convert_genename_fromgtf.pl --type=isoforms -f $output.transcript.$norm.tsv -g $gtf --nline=0 \
            > $output.transcript.$norm.tsv.temp #$output.transcript.$norm.withname.tsv
    mv $output.transcript.$norm.tsv.temp $output.transcript.$norm.tsv

    echo "Adding gene annotation to $output.transcript.annotated.tsv..."
    add_geneinfo_fromRefFlat.pl isoforms $output.transcript.$norm.tsv $refFlat_transcript 1 \
            > $output.transcript.$norm.annotated.tsv
done

### Gene level
echo "tximport to gene..."
Rscript /opt/RumBall/kallisto_tximport.R $output.genes $gtf $files
#Rscript /work3/DockerFiles/RumBall/Dockerfiles/RumBall/kallisto_tximport.R $output.genes $gtf $files

# Add header
tmpfile=$(mktemp)

for norm in TPM count
do
    outputfile=$output.genes.$norm.tsv
    for file in $files; do
        echo -en "\t`echo  $file | sed -e 's/kallisto\///g' -e 's/\/abundance.tsv//g'`" >> $tmpfile
    done
    echo "" >> $tmpfile
    cat $outputfile >> $tmpfile
    mv $tmpfile $outputfile

    for genetype in all pc; do
    convert_genename_fromgtf.pl --type=genes --outputtype=$genetype -f $outputfile -g $gtf --nline=0 > $output.genes.$norm.$genetype.tsv
    echo "Adding gene annotation to $output.genes.$norm.$genetype.annotated.tsv..."
    add_geneinfo_fromRefFlat.pl genes $output.genes.$norm.$genetype.tsv  $refFlat_gene 1 > $output.genes.$norm.$genetype.annotated.tsv
      done
done

echo "convert tsv to xlsx..."
csv2xlsx.pl \
  -i $output.genes.TPM.all.annotated.tsv -n gene-TPM.all \
  -i $output.genes.TPM.pc.annotated.tsv -n gene-TPM.proteincoding \
  -i $output.genes.count.all.annotated.tsv -n gene-count.all \
  -i $output.genes.count.pc.annotated.tsv -n gene-count.proteincoding \
  -i $output.transcript.TPM.annotated.tsv -n transcript-TPM \
  -i $output.transcript.count.annotated.tsv -n transcript-count \
  -o $output.xlsx
echo "done."
