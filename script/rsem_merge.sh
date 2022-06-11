#!/bin/bash -e
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-s <strings for sed>] <inputdirs> <prefix> <Ddir>" 1>&2
    echo '   <inputdirs>: directories of samples (should be quoted)' 1>&2
    echo '   <prefix>: prefix of output files' 1>&2
    echo '   <Ddir>: directory of index and gtf files' 1>&2
    echo '   Options:' 1>&2
    echo '      -s <strings for sed>: specify strings that you want to remove from sample labels (e.g., "HeLa_", multiple strings should be separated by spaces)' 1>&2
    echo "   Example:" 1>&2
    echo "      $cmdname \"star/Ctrl1 star/Ctrl2 star/siCTCF1 star/siCTCF2\" Matrix_edgeR/HEK293 $Ddir" 1>&2
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

if [ $# -ne 3 ]; then
  usage
  exit 1
fi

files=$1
outname=$2
Ddir=$3

gtf=$Ddir/gtf_chrUCSC/chr.gtf

for str in genes isoforms; do
    s=""
    for prefix in $files; do s="$s $prefix.$str.results"; done

    for tp in count TPM; do
	    head=$outname.$str.$tp
	    echo "generate $head.txt..."
	    rsem-generate-data-matrix-modified $tp $s > $head.txt

	    # 余計な文字列の除去
	    cat $head.txt | sed -e 's/.'$str'.results//g' > $head.temp
	    mv $head.temp $head.txt
	    for rem in $str_sed; do
	        cat $head.txt | sed -e 's/'$rem'//g' > $head.temp
	        mv $head.temp $head.txt
	    done

    done
done

# Add gene annotation from geneid
for str in genes isoforms; do
    if test $str = "genes"; then
	nline=0
	refFlat=$Ddir/gtf_chrUCSC/chr.gene.refFlat
    else
	nline=0
	refFlat=$Ddir/gtf_chrUCSC/chr.transcript.refFlat
    fi
    for tp in count TPM; do
	head=$outname.$str.$tp
	echo "add genename to $head.txt..."
	add_geneinfo_fromRefFlat.pl $str $head.txt $refFlat $nline > $head.temp.txt
	convert_genename_fromgtf.pl --type=$str -f $head.temp.txt -g $gtf --nline=$nline > $head.txt
	rm $head.temp.txt
    done
done

# generate xlsx file
echo "generate xlsx..."
s=""
for str in genes isoforms; do
    for tp in count TPM; do
	head=$outname.$str.$tp
	s="$s -i $head.txt -n $str-$tp"
    done
done

csv2xlsx.pl $s -o $outname.xlsx
