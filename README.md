# RumBall: Docker image for RNA-seq analysis

## 1. Installation

Docker image is available at [DockerHub](https://hub.docker.com/r/rnakato/rumball).

### 1.1 Docker 
To use docker command, type:

    docker pull rnakato/rumball
    docker run -it --rm rnakato/rumball <command>

### 1.2 Singularity

Singularity can also be used to execute the docker image:

    singularity build rumball.sif docker://rnakato/rumball
    singularity exec rumball.sif <command>

Singularity mounts the current directory automatically. If you access the files in the other directory, please mount by `--bind` option, for instance:

    singularity exec --bind /work rumball.sif <command>
    
This command mounts `/work` directory.

## 2. Tutorial

Generate the database (genome, gene annotation and index file):

    build=GRCh38  # specify the build (Ensembl) that you need
    Ddir=Ensembl-$build/
    mkdir -p log
    # Download genome and gtf
    download_genomedata.sh $build $Ddir 2>&1 | tee log/Ensembl-$build
    # make index for STAR-RSEM 
    build-index.sh rsem-star $build $Ddir

Command example:

    # mapping reads by STAR-RSEM 
    for prefix in Ctrl1 Ctrl2 siCTCF1 siCTCF2; do
       fq1=fastq/${prefix}_1.fq.gz
       fq2=fastq/${prefix}_2.fq.gz
       star.sh paired $prefix "$fq1 $fq2" $Ddir reverse > log/$prefix.star.sh
    done
    
    # For DESeq2
    mkdir -p Matrix_deseq2
    rsem_merge.sh "star/Ctrl1 star/Ctrl2 star/siCTCF1 star/siCTCF2" Matrix_deseq2/siCTCF $Ddir "XXX"
    edgeR.sh Matrix_deseq2/siCTCF 2:2 Control:siCTCF
    
    # For edgeR
    mkdir -p Matrix_edgeR
    rsem_merge.sh "star/Ctrl1 star/Ctrl2 star/siCTCF1 star/siCTCF2" Matrix_edgeR/siCTCF $Ddir "XXX"
    edgeR.sh Matrix_edgeR/siCTCF 2:2 Control:siCTCF

## 3. Commands in RumBall

### 3.1 star.sh: execute STAR and RSEM

#### Usage

    star.sh <single|paired> <output prefix> <fastq> <Ensembl|UCSC> <build> <--forward-prob>

For `--forward-prob`, supply 0 for stranded RNA-seq and 0.5 for unstranded RNA-seq.

Output:
* mapfile for a genome (star/*.Aligned.sortedByCoord.out.bam)
* mapfile for genes (star/*.Aligned.toTranscriptome.out.bam)
* gene expression data (star/*.genes.results)
* transcript expression data (star/*.isoforms.results)
* mapping stats (log/star-*.txt)

log example:

|Sequenced	|Uniquely mapped|	(%)	|Mapped to multiple loci|	(%)|	Mapped to too many loci|	(%)|	Unmapped (too many mismatches)	|Unmapped (too short)	|Unmapped (other)	|chimeric reads|	(%)	|Splices total	|Annotated	|(%)	|Non-canonical	|(%)	|Mismatch rate per base (%)|	Deletion rate per base (%)	|Insertion rate per base (%)|
----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----
|29446992	|27430449	|93.15	|1012811	|3.44	|5253	|0.02	|0%|	3%	|0%	|0	|0	|18960488	|18725703	|98.76	|30590	|0.16	|0.19	|0.01	|0.01|

### 3.2 rsem_merge.sh: merge expression data of multiple samples

    rsem_merge.sh <files> <output> <Ddir> <strings for removal>

Output:
* gene expression data: *.genes.<TPM|count>.<build>.txt
* transcript expression data: *.isoforms.<TPM|count>.<build>.txt
* merged xlsx file: *.<build>.xlsx 

### 3.3 edgeR.sh: differential expression analysis for two groups by edgeR

    edgeR.sh <Matrix> <num of reps> <groupname>

Output
* merged xlsx: *.<genes|isoforms>.count.<build>.edgeR.xlsx
* BCV/MDS plot: *.<genes|isoforms>.count.<build>.BCV-MDS.pdf
* MA plot:  *.<genes|isoforms>.count.<build>.MAplot.pdf

### 3.4 DESeq2.sh: differential expression analysis for two groups by DESeq2

    DESeq2.sh [-a] <Matrix><num of reps> <groupname>

Output
* merged xlsx: *.<genes|isoforms>.count.<build>.edgeR.xlsx
* BCV/MDS plot: *.<genes|isoforms>.count.<build>.BCV-MDS.pdf
* MA plot:  *.<genes|isoforms>.count.<build>.MAplot.pdf


### 3.5 Utility scripts in RumBall
    
#### csv2xlsx.pl
merge csv/tsv files to a single xlsx file

    csv2xlsx.pl -i file1.tsv -n tabname1 [-i file2.tsv -n tabname2 ...] -o output.xlsx
    Options:
          -d --delim=<str>: delimiter of input files (default:\t)

## 4. Build Docker image from Dockerfile

First clone and move to the repository

    git clone https://github.com/rnakato/RumBall.git
    cd RumBall

Then type:

    docker build -t <account>/rumball

## 5. Contact

Ryuichiro Nakato: rnakato AT iqb.u-tokyo.ac.jp
