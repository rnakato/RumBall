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

sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/rumball.0.5.2.sif"
#sing="singularity exec rumball.sif"

Ddir=Ensembl-GRCh38/

mkdir -p log
for ((i=0; i<${#ID[@]}; i++))
do
    echo ${NAME[$i]}
    fq1=fastq/${ID[$i]}_1.fastq.gz
    fq2=fastq/${ID[$i]}_2.fastq.gz
    $sing bowtie2.sh paired ${NAME[$i]} "$fq1 $fq2" $Ddir reverse > log/bowtie2.sh.${NAME[$i]}
done

Ctrl="bowtie2/HEK293_Control_rep1 bowtie2/HEK293_Control_rep2"
siCTCF="bowtie2/HEK293_siCTCF_rep1 bowtie2/HEK293_siCTCF_rep2"

# For DESeq2
mkdir -p Matrix_edgeR_bowtie2
rsem_merge.sh "$Ctrl $siCTCF" Matrix_edgeR_bowtie2/HEK293 $Ddir
DESeq2.sh Matrix_edgeR_bowtie2/HEK293 2:2 Control:siCTCF Human

# For edgeR
mkdir -p Matrix_deseq2_bowtie2
rsem_merge.sh "$Ctrl $siCTCF" Matrix_deseq2_bowtie2/HEK293 $Ddir
edgeR.sh Matrix_deseq2_bowtie2/HEK293 2:2 Control:siCTCF Human
