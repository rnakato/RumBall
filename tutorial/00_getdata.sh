mkdir -p fastq
for id in SRR710092 SRR710093 SRR710094 SRR710095
do
    fastq-dump --gzip $id --split-files -O fastq
done

# download data
mkdir -p log
sing="singularity exec --bind /work,/work2 /work/SingularityImages/rumball.0.3.0.sif"
build=GRCh38
ncore=24
$sing download_genomedata.sh $build Ensembl-$build/ 2>&1 | tee log/Ensembl-$build

# make index
$sing build-index.sh -p $ncore rsem-star $build Ensembl-$build
$sing build-index.sh -p $ncore rsem-bowtie2 $build Ensembl-$build
$sing build-index.sh -p $ncore kallisto  $build Ensembl-$build
