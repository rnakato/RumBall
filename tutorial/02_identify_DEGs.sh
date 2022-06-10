db=Ensembl
build=GRCh38
Ddir=/work/Database/Database_fromDocker/Ensembl-GRCh38/

sing="singularity exec --bind /work,/work2 /work/SingularityImages/rumball.0.1.0.sif"
Ctrl="star/HEK293_Control_rep1 star/HEK293_Control_rep2"
siCTCF="star/HEK293_siCTCF_rep1 star/HEK293_siCTCF_rep1"

mkdir -p Matrix_edgeR
$sing rsem_merge.sh "$Ctrl $siCTCF" Matrix_edgeR/HEK293 $Ddir "XXX"
$sing edgeR.sh Matrix_edgeR/HEK293 2:2 Control:NIPBLKD

mkdir -p Matrix_deseq2
$sing rsem_merge.sh "$Ctrl $siCTCF" Matrix_deseq2/HEK293 $Ddir "XXX"
$sing DESeq2.sh Matrix_deseq2/HEK293 2:2 Control:NIPBLKD
