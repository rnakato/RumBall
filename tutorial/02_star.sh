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

db=Ensembl
build=GRCh38
sing="singularity exec --bind /work,/work2 /work/SingularityImages/rumball.0.1.0.sif"
Ddir=Ensembl-GRCh38/

mkdir -p log
for ((i=0; i<${#ID[@]}; i++))
do
    echo ${NAME[$i]}
    fq1=fastq/${ID[$i]}_1.fastq.gz
    fq2=fastq/${ID[$i]}_2.fastq.gz
    $sing star.sh paired ${NAME[$i]} "$fq1 $fq2" $Ddir reverse > log/star.sh.${NAME[$i]}
done
