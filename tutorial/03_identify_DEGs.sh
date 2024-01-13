sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/rumball.0.5.2.sif"
#sing="singularity exec rumball.sif"

Ddir=Ensembl-GRCh38/

Ctrl="star/HEK293_Control_rep1 star/HEK293_Control_rep2"
siCTCF="star/HEK293_siCTCF_rep1 star/HEK293_siCTCF_rep2"

mkdir -p Matrix_edgeR
#$sing rsem_merge.sh "$Ctrl $siCTCF" Matrix_edgeR/HEK293 $Ddir
#$sing edgeR.sh Matrix_edgeR/HEK293 2:2 Control:siCTCF Human

mkdir -p Matrix_deseq2
#$sing rsem_merge.sh "$Ctrl $siCTCF" Matrix_deseq2/HEK293 $Ddir
$sing DESeq2.sh Matrix_deseq2/HEK293 2:2 Control:siCTCF Human
