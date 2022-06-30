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

echo "merging csv files..."
mergekallistotsv.sh $files > $output.transcript.csv
convert_genename_fromgtf.pl --type=isoforms -f $output.transcript.csv -g $gtf --nline=0 > $output.transcript.name.csv

echo "tximport to gene..."
Rscript /opt/script/kallisto_tximport.R $output.gene $gtf $files

tmpfile=$(mktemp)
for file in $files
do
  echo -en "\t`echo  $file | sed -e 's/kallisto\///g' -e 's/\/abundance.tsv//g'`" >> $tmpfile
done
echo "" >> $tmpfile
cat $output.gene.csv >> $tmpfile
mv $tmpfile $output.gene.csv

echo "convert csv to xlsx..."
convert_genename_fromgtf.pl --type=genes --outputtype=all -f $output.gene.csv -g $gtf --nline=0 > $output.gene.name.all.csv
convert_genename_fromgtf.pl --type=genes --outputtype=pc  -f $output.gene.csv -g $gtf --nline=0 > $output.gene.name.pc.csv
csv2xlsx.pl -i $output.gene.name.all.csv -n gene-TPM.all -i $output.gene.name.pc.csv -n gene-TPM.proteincoding -i $output.transcript.name.csv -n isoform-TPM -o $output.xlsx
echo "done."
