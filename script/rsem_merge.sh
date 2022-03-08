#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <files> <output> <Ensembl|UCSC> <build> <gtf> <strings for sed>" 1>&2
}

name=0
while getopts n option
do
    case ${option} in
        n)
            name=1
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

files=$1
outname=$2
db=$3
build=$4
gtf=$5
str_sed=$6

Ddir=`database.sh`

if test $db = "Ensembl"; then
    strs="genes isoforms"
else
    strs="genes"
fi

for str in $strs
do
    s=""
    for prefix in $files; do s="$s $prefix.$build.$str.results"; done

    for tp in count TPM; do
	    head=$outname.$str.$tp.$build
	    echo "generate $head.txt..."
	    rsem-generate-data-matrix-modified $tp $s > $head.txt

	    # 余計な文字列の除去
	    cat $head.txt | sed -e 's/.'$build'.'$str'.results//g' > $head.temp
	    mv $head.temp $head.txt
	    for rem in $str_sed; do
	        cat $head.txt | sed -e 's/'$rem'//g' > $head.temp
	        mv $head.temp $head.txt
	    done

    done
done

# isoformのファイルにgene idを追加
#if test $db = "Ensembl"; then
#    for tp in count TPM
#    do
#        head=$outname.isoforms.$tp.$build
#        echo "add geneID to $head.txt..."
        #    add_genename_fromgtf.pl $head.txt $gtf > $head.addname.txt
#        convert_genename_fromgtf.pl --type=isoforms -f $head.txt -g $gtf --nline=0 > $head.addname.txt

#        mv $head.addname.txt $head.txt
#    done
#fi

# IDから遺伝子情報を追加

d=`echo $build | sed -e 's/.proteincoding//g'`
if test $db = "Ensembl"; then
    for str in $strs; do
    if test $str = "genes"; then
	    nline=0
	    refFlat=`ls $Ddir/$db/$d/release1*/gtf_chrUCSC/*.$build.1*.chr.gene.refFlat | tail -n1`
    else
	    nline=0
	    refFlat=`ls $Ddir/$db/$d/release1*/gtf_chrUCSC/*.$build.1*.chr.transcript.refFlat | tail -n1`
    fi
    for tp in count TPM; do
	    head=$outname.$str.$tp.$build
	    echo "add genename to $head.txt..."
	    add_geneinfo_fromRefFlat.pl $str $head.txt $refFlat $nline > $head.temp.txt
	    convert_genename_fromgtf.pl --type=$str -f $head.temp.txt -g $gtf --nline=$nline > $head.txt
	    rm $head.temp.txt
    done
done
fi

# xlsxファイル作成
echo "generate xlsx..."
s=""
for str in $strs; do
    for tp in count TPM; do
	    head=$outname.$str.$tp.$build
	    s="$s -i $head.txt -n $str-$tp"
    done
done

csv2xlsx.pl $s -o $outname.$build.xlsx
