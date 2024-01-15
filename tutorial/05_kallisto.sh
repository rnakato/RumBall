#!/bin/bash

ID=(
    "SRR710092"
    "SRR710093"
    "SRR710094"
    "SRR710095"
)
NAME=(
    "HEK293_Control_rep1"
    "HEK293_Control_rep2"
    "HEK293_siCTCF_rep1"
    "HEK293_siCTCF_rep2"
)

#sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/rumball.0.6.0.sif"
sing="singularity exec rumball.sif"

Ddir=Ensembl-GRCh38/

mkdir -p log kallisto
for ((i=0; i<${#ID[@]}; i++))
do
    echo ${NAME[$i]}
    fq1=fastq/${ID[$i]}_1.fastq.gz
    fq2=fastq/${ID[$i]}_2.fastq.gz
    index=$Ddir/kallisto-indexes/genome
    $sing kallisto.sh -p 64 ${NAME[$i]} "$fq1 $fq2" $Ddir reverse
done

s=""
for ((i=0; i<${#ID[@]}; i++))
do
    s="$s kallisto/${NAME[$i]}/abundance.tsv"
done

# For DESeq2
mkdir -p Matrix_deseq2_kallisto
$sing kallisto_merge.sh "$s" Matrix_deseq2_kallisto/HEK293 $Ddir
$sing DESeq2.sh -k Matrix_deseq2_kallisto/HEK293 2:2 Control:siCTCF Human

# For edgeR
mkdir -p Matrix_edgeR_kallisto
$sing kallisto_merge.sh "$s" Matrix_edgeR_kallisto/HEK293 $Ddir
$sing edgeR.sh -k Matrix_edgeR_kallisto/HEK293 2:2 Control:siCTCF Human
