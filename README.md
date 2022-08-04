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

This tutorial assumes using singularity image. So please add `singularity exec rumball.sif` before the commands.

### 2.1 Get data

Here we use four mRNA-seq samples of HEK293 cells (siCTCF and control from [Zuin et al., PNAS, 2014](https://pubmed.ncbi.nlm.nih.gov/24335803/)):

    mkdir -p fastq
    for id in SRR710092 SRR710093 SRR710094 SRR710095
    do
        fastq-dump --gzip $id --split-files -O fastq
    done

Then download and generate the reference dataset including genome, gene annotation and index files.
**RumBall** contains several scripts to do that:

    build=GRCh38  # specify the build (Ensembl) that you need
    Ddir=Ensembl-$build/
    mkdir -p log
    
    # Download genome and gtf
    download_genomedata.sh $build $Ddir 2>&1 | tee log/Ensembl-$build
    
    # make index for STAR-RSEM 
    ncore=12 # number of CPUs 
    build-index.sh -p $ncore rsem-star $build $Ddir
    
### 2.1 Check Strandedness

If the strandedness of RNA-seq data is not clear, you can briefly check by this command: 

    $ check_stranded.sh human fastq/SRR710092_1.fastq.gz
    # reads processed: 56830606
    # reads with at least one alignment: 27787970 (48.90%)
    # reads that failed to align: 29042636 (51.10%)
    Reported 27787970 alignments
     540264 +
    27247706 -

In this example, majority of reads were mapped on - strand, so this RNA-seq is stranded.

### 2.2 Mapping by STAR

RumBall can allow STAR, bowtie2, kallisto and salmon for mapping. Here we use STAR.
The reads are then parsed by RSEM:

    mkdir -p log
    star.sh paired HEK293_Control_rep1 fastq/SRR710092_1.fastq.gz fastq/SRR710092_2.fastq.gz Ensembl-GRCh38/ reverse > log/HEK293_Control_rep1.star.sh
    star.sh paired HEK293_Control_rep2 fastq/SRR710093_1.fastq.gz fastq/SRR710093_2.fastq.gz Ensembl-GRCh38/ reverse > log/HEK293_Control_rep2.star.sh
    star.sh paired HEK293_siCTCF_rep1 fastq/SRR710094_1.fastq.gz fastq/SRR710094_2.fastq.gz Ensembl-GRCh38/ reverse > log/HEK293_siCTCF_rep1.star.sh
    star.sh paired HEK293_siCTCF_rep2 fastq/SRR710095_1.fastq.gz fastq/SRR710095_2.fastq.gz Ensembl-GRCh38/ reverse > log/HEK293_siCTCF_rep2.star.sh
 
 Of course you can also use a shell loop:
 
    ID=("SRR710092" "SRR710093" "SRR710094" "SRR710095")
    NAME=("HEK293_Control_rep1" "HEK293_Control_rep2" "HEK293_siCTCF_rep1" "HEK293_siCTCF_rep2")

    mkdir -p log
    for ((i=0; i<${#ID[@]}; i++))
    do
        echo ${NAME[$i]}
        fq1=fastq/${ID[$i]}_1.fastq.gz
        fq2=fastq/${ID[$i]}_2.fastq.gz
        star.sh paired ${NAME[$i]} "$fq1 $fq2" $Ddir reverse > log/${NAME[$i]}.star.sh
    done
 
### 2.3 Differential analysis 
 
 `rsem_merge.sh` merges the RSEM output of all samples. The generated matrix can be applied to DESeq2 or edgeR to identify differentially expressed genes between two groups:

    Ctrl="star/HEK293_Control_rep1 star/HEK293_Control_rep2"
    siCTCF="star/HEK293_siCTCF_rep1 star/HEK293_siCTCF_rep1"
    # For DESeq2
    mkdir -p Matrix_deseq2
    rsem_merge.sh "$Ctrl $siCTCF" Matrix_deseq2/HEK293 $Ddir
    DESeq2.sh Matrix_deseq2/HEK293 2:2 Control:siCTCF
    
    # For edgeR
    mkdir -p Matrix_edgeR
    rsem_merge.sh "$Ctrl $siCTCF" Matrix_edgeR/HEK293 $Ddir
    edgeR.sh Matrix_edgeR/HEK293 2:2 Control:siCTCF

### 2.4 Analysis with RSEM-bowtie2

STAR requires large memory for mapping. Bowtie2 requires less memory with comparable mapping accuracy. 
Here we show the example using Bowtie2.:

    # make index for bowtie2-RSEM
    build=GRCh38  # specify the build (Ensembl) that you need
    Ddir=Ensembl-$build/
    ncore=12  # number of CPUs 
    build-index.sh -p $ncore rsem-bowtie2 $build $Ddir


## 3. Commands in RumBall

### download_genomedata.sh

`download_genomedata.sh` downloads the genome and gene annotation files of the genome build specified.
**RumBall** assumes the reference data is downloaded bu this command.

    download_genomedata.sh <build> <outputdir>
      build:
             human (GRCh38, GRCh37)
             mouse (GRCm39, GRCm38)
             rat (mRatBN7.2)
             fly (BDGP6)
             zebrafish (GRCz11)
             chicken (GRCg6a)
             African clawed frog (xenLae2)
             C. elegans (WBcel235)
             S. serevisiae (R64-1-1)
             S. pombe (SPombe)
      Example:
             download_genomedata.sh GRCh38 Ensembl-GRCh38


### build-index.sh: build index for RNA-seq

`build-index.sh` builds index files of the tools specified. `<odir>` should be the same with `<outputdir>` directory provided in `download_genomedata.sh`. 
This `<odir>` is used in the **RumBall** commands below.

    build-index.sh [-p ncore] -a <program> <build> <odir>
      -a: use genome_full.fa
      program: rsem-star, rsem-bowtie2, hisat2, kallisto, salmon
      build (only for hisat2):
             human (GRCh38, GRCh37)
             mouse (GRCm39, GRCm38)
             rat (mRatBN7.2)
             fly (BDGP6)
             zebrafish (GRCz11)
                 C. elegans (WBcel235)
             S. serevisiae (R64-1-1)
      Example:
             build-index.sh rsem-star GRCh38 Ensembl-GRCh38

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
* gene expression data: *.genes.<TPM|count>.txt
* transcript expression data: *.isoforms.<TPM|count>.txt
* merged xlsx file: *.xlsx 


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

Output:
* Matrix.*.count.DESeq2.all.tsv ... list of all genes
* Matrix.*.count.DESeq2.DEGs.tsv ... list of all DEGs
* Matrix.*.count.DESeq2.upDEGs.tsv ... list of all upregulated DEGs
* Matrix.*.count.DESeq2.downDEGs.tsv ... list of all upregulated DEGs
* Matrix.*.count.DESeq2.xlsx ... xlsx file that include all .tsv files above
* Matrix.*.count.DEGs.bed ... BED file of DEGs
* Matrix.*.count.DEGs.bed6 ... BED6 file of DEGs that contain gene name, length and strand information

* Matrix.*.count.DESeq2.Dispersionplot.pdf ... Dispersion plot of log-scale gene expression before and after dispersion fitting
* Matrix.*.count.DESeq2.MAplot.pdf ... MA plot of all genes. Significantly differential genes are highlighted in red. "shrunken apeglm" removes the high variance of low expression genes.
* Matrix.*.count.DESeq2.Volcano.pdf ... Volcano plot of all genes. Top-ranked genes are labeled.
* Matrix.*.count.DESeq2.HighlyExpressedGenes.pdf ... Heatmap of top-ranked DEGs
* Matrix.*.count.DESeq2.sampleClustering.pdf ... Clustering results of sample-wide comparison
* Matrix.*.count.DESeq2.samplePCA.pdf ... PCA plot of samples based on gene expression level
    
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
* Matrix.*.count.edgeR.all.tsv ... list of all genes
* Matrix.*.count.edgeR.DEGs.tsv ... list of all DEGs
* Matrix.*.count.edgeR.upDEGs.tsv ... list of all upregulated DEGs
* Matrix.*.count.edgeR.downDEGs.tsv ... list of all downregulated DEGs
* Matrix.*.count.edgeR.xlsx ... xlsx file that include all .tsv files above
* Matrix.*.count.DEGs.bed ... BED file of DEGs
* Matrix.*.count.DEGs.bed6 ... BED6 file of DEGs that contain gene name, length and strand information

* Matrix.*.count.density.png ... Gene expression distribution (log scale)
* Matrix.*.count.QQplot.1stSample.pdf ... QQplot of the 1st sample
* Matrix.*.count.edgeR.BCV-MDS.pdf ... BCV and MDS plots for estimating variance among input samples
* Matrix.*.count.edgeR.MAplot.pdf ... MA plot of all genes. Significantly differential genes are highlighted in red. "shrunken apeglm" removes the high variance of low expression genes.
* Matrix.*.count.heatmap.0.01.png ... Heatmap of DEGs
* Matrix.*.count.samplesCluster.inDEGs.pdf ... Hierarchical tree of samples obtained the heatmap above
* Matrix.*.count.edgeR.Volcano.pdf ... Volcano plot of all genes. Top-ranked genes are labeled.
* Matrix.*.count.samplePCA.pdf ... PCA plot of samples based on gene expression level
          
## 4. Utility scripts in RumBall
   
### check_stranded.sh
           
In case that it is not clear whether the input samples are stranded or not, use `check_stranded.sh` for the quick check.

    check_stranded.sh [human|mouse] <fastq>

This command runs bowtie to map reads onto the mRNA sequences obtained from NCBI. If the samples are reverse-straned, the most reads will be mapped to the reverse strand.
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
