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

Ddir=/work/Database/Database_fromDocker/Ensembl-GRCh38/

mkdir -p log
for ((i=0; i<${#ID[@]}; i++))
do
    echo ${NAME[$i]}
    fq1=fastq/${ID[$i]}_1.fastq.gz
    fq2=fastq/${ID[$i]}_2.fastq.gz
    $sing star.sh paired ${NAME[$i]} "$fq1 $fq2" $Ddir reverse > log/${NAME[$i]}.star.sh
done

exit

mkdir -p Matrix
$sing rsem_merge.sh "star/2015_012B_7_0 star/2015_012B_7_30 star/2015_012B_7_0 star/2015_012B_7_30" Matrix/test $Ddir $db $build "2015_012B_"
#$sing edgeR.sh Matrix/test $build 2:2 Control:NIPBLKD 0.01
$sing DESeq2.sh Matrix/test $build 2:2 Control:NIPBLKD 0.01

exit

Con="star/2015_012B_Control_0 star/2015_012B_Control_30 star/2015_012B_Control_60 star/2015_012B_Control_120"
KD7="star/2015_012B_7_0 star/2015_012B_7_30 star/2015_012B_7_60 star/2015_012B_7_120"
KD8="star/2015_012B_8_0 star/2015_012B_8_30 star/2015_012B_8_60 star/2015_012B_8_120"

gtf=/work/Database/Ensembl/GRCh38/release103/gtf_chrUCSC/Homo_sapiens.GRCh38.103.chr.gtf
mkdir -p Matrix
rsem_merge.sh "$Con $KD7 $KD8" Matrix/RPE.NIPBLKD $db $build $gtf "2015_012B_"
edgeR.sh Matrix/RPE.NIPBLKD $db $build 4:8 Control:NIPBLKD 0.01
rsem_merge.sh "$Con $KD7" Matrix/RPE.NIPBLKD7 $db $build $gtf "2015_012B_"
edgeR.sh Matrix/RPE.NIPBLKD7 $db $build 4:4 Control:NIPBLKD 0.01
rsem_merge.sh "$Con $KD8" Matrix/RPE.NIPBLKD8 $db $build $gtf "2015_012B_"
edgeR.sh Matrix/RPE.NIPBLKD8 $db $build 4:4 Control:NIPBLKD 0.01
