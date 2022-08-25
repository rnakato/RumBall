#!/bin/bash -e
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <inputfile> <num of reps> <groupname>" 1>&2
    echo '   <inputfile>: prefix of input matrix file' 1>&2
    echo '   <Ddir>: directory of gene annotation files' 1>&2
    echo '   <num of reps>: number of replicates (quated by ":")' 1>&2
    echo '   <group name>: labels of two groups compared (quated by ":")' 1>&2
    echo '   Options:' 1>&2
    echo '      -t <FDR>: FDR threshould (default: 0.05)' 1>&2
    echo "  Example:" 1>&2
    echo "   $cmdname Matrix 2:2 WT:KD" 1>&2
}

p=0.05
while getopts t: option
do
    case ${option} in
        t) p=${OPTARG};;
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

outname=$1
n=$2
gname=$3

n1=$(cut -d':' -f1 <<<${n})
n2=$(cut -d':' -f2 <<<${n})

R="Rscript /opt/script/edgeR.R"

ex(){ echo $1; eval $1; }

postfix=count
ex "$R -i=$outname.genes.$postfix.txt -n=$n -gname=$gname -o=$outname.genes.$postfix -p=$p -nrowname=2 -ncolskip=1"
ex "$R -i=$outname.isoforms.$postfix.txt -n=$n -gname=$gname -o=$outname.isoforms.$postfix -p=$p -nrowname=2 -ncolskip=1 -color=orange"

for str in genes isoforms; do
    for ty in DEGs upDEGs downDEGs; do
       head=$outname.$str.$postfix.edgeR.$ty
       ncol=`head -n1 $head.tsv | awk '{print NF}'`
       n1=$((ncol-6))
       n2=$((ncol-5))
       n3=$((ncol-4))
       n4=$((ncol-3))
       n5=$((ncol-2))
       cut -f$n1,$n3,$n4 $head.tsv | grep -v chromosome > $head.bed
       grep -v chromosome $head.tsv | awk 'BEGIN { OFS="\t" } {print $'$n1', $'$n3', $'$n4', $2, $'$n5', $'$n2' }' > $head.bed6
    done

    s=""
    for ty in all DEGs upDEGs downDEGs; do
        head=$outname.$str.$postfix.edgeR.$ty
        s="$s -i $head.tsv -n fitted-$str-$ty"
    done

    csv2xlsx.pl $s -o $outname.$str.$postfix.edgeR.xlsx
done
