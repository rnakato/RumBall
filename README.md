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

Command example (assuming the comparison of "Ctrl" and "siCTCF" with two replicates):

    # mapping reads by STAR-RSEM 
    # output directory is "star/"
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

### star.sh: execute STAR and RSEM

    star.sh [Options] <single|paired> <prefix> <fastq> <Ddir> <strandedness>
       <single|paired>: single-end or paired-end reads
       <prefix>: prefix of output files
       <fastq>: fastq files (should be quoted if paired-end)
       <Ddir>: directory of index and gtf files
       <strandedness [none|forward|reverse]>: strandedness of input fastq files ("reverse" in the most cases)
      Options:
          -d outputdir: Output directory (default: "star/")
          -p ncore: number of CPUs (default: 12, note that large number (e.g., 64) may cause an error in STAR)
       Example:
          star.sh single HeLa_rep1 HeLa_rep1.fastq.gz Ensembl-GRCh38 reverse
          star.sh paired HeLa_rep1 "HeLa_rep1_1.fastq.gz HeLa_rep1_2.fastq.gz" Ensembl-GRCh38 reverse

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

### rsem_merge.sh: merge expression data of multiple samples

    rsem_merge.sh [-s <strings for sed>] <inputdirs> <prefix> <Ddir>
       <inputdirs>: directories of samples (should be quoted)
       <prefix>: prefix of output files
       <Ddir>: directory of index and gtf files
       Options:
          -s <strings for sed>: specify strings that you want to remove from sample labels (e.g., "HeLa_", multiple strings should be separated by spaces)
       Example:
          rsem_merge.sh "star/Ctrl1 star/Ctrl2 star/siCTCF1 star/siCTCF2" Matrix_edgeR/HEK293

Output:
* gene expression data: *.genes.<TPM|count>.<build>.txt
* transcript expression data: *.isoforms.<TPM|count>.<build>.txt
* merged xlsx file: *.<build>.xlsx 

### edgeR.sh: differential expression analysis for two groups by edgeR

    edgeR.sh [Options] <inputfile> <num of reps> <groupname>
       <inputfile>: prefix of input matrix file
       <Ddir>: directory of gene annotation files
       <num of reps>: number of replicates (quated by ":")
       <group name>: labels of two groups compared (quated by ":")
       Options:
          -t <FDR>: FDR threshould (default: 0.05)
      Example:
       edgeR.sh Matrix 2:2 WT:KD

Output
* merged xlsx: *.<genes|isoforms>.count.<build>.edgeR.xlsx
* BCV/MDS plot: *.<genes|isoforms>.count.<build>.BCV-MDS.pdf
* MA plot:  *.<genes|isoforms>.count.<build>.MAplot.pdf

### DESeq2.sh: differential expression analysis for two groups by DESeq2

    DESeq2.sh [Options] <inputfile> <num of reps> <groupname>
       <inputfile>: prefix of input matrix file
       <Ddir>: directory of gene annotation files
           <num of reps>: number of replicates (quated by ":")
       <group name>: labels of two groups compared (quated by ":")
       Options:
          -t <FDR>: FDR threshould (default: 0.05)
       Example:
          DESeq2.sh star/Matrix 2:2 WT:KD

Output
* merged xlsx: *.<genes|isoforms>.count.<build>.edgeR.xlsx


## 4. Utility scripts in RumBall
   
### check_stranded.sh
           
In case that it is not clear whether the input samples are stranded or not, use `check_stranded.sh` for the quick check.

    check_stranded.sh [human|mouse] <fastq>

This command runs bowtie to map reads onto the NCBI allrna. If the samples are reverse-straned, the most reads will be mapped to the reverse strand.
If fifty-fifty, the samples are unstranded.

           
### csv2xlsx.pl
This command merges csv/tsv files to a single xlsx file.

    csv2xlsx.pl -i file1.tsv -n tabname1 [-i file2.tsv -n tabname2 ...] -o output.xlsx
    Options:
          -d --delim=<str>: delimiter of input files (default:\t)
           
## 5. Build Docker image from Dockerfile

First clone and move to the repository

    git clone https://github.com/rnakato/RumBall.git
    cd RumBall

Then type:

    docker build -t <account>/rumball

## 6. Contact

Ryuichiro Nakato: rnakato AT iqb.u-tokyo.ac.jp
