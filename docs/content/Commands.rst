Commands in RumBall
============================

.. contents::
   :depth: 2

download_genomedata.sh
------------------------------------

``download_genomedata.sh`` downloads the genome and gene annotation files of the genome build specified.
**RumBall** assumes the reference data is downloaded by this command.

.. code-block:: bash

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
             S. cerevisiae (R64-1-1)
             S. pombe (SPombe)
      Example:
             download_genomedata.sh GRCh38 Ensembl-GRCh38


build-index-RNAseq.sh: build index for RNA-seq
-----------------------------------------------------

(From the **RumBall** version 0.4.2, ``build-index.sh`` is renamed to ``build-index-RNAseq.sh``.)

``build-index-RNAseq.sh`` builds index files of the tools specified. ``<odir>`` should be the same with ``<outputdir>`` directory
provided in ``download_genomedata.sh``.
The ``<odir>`` is used in the **RumBall** commands below.

.. code-block:: bash

    build-index-RNAseq.sh [Options] <program> <build> <odir>
      <program>: rsem-star, rsem-bowtie2, hisat2, kallisto, salmon
      <build> (only for hisat2):
             human (GRCh38, GRCh37)
             mouse (GRCm39, GRCm38)
             rat (mRatBN7.2)
             fly (BDGP6)
             zebrafish (GRCz11)
             C. elegans (WBcel235)
             S. cerevisiae (R64-1-1)
             S. pombe (SPombe)
      <odir>: outout directory
       Options:
          -a: consider all scaffolds (default: chromosomes only)
          -p: number of CPUs (default: 4)
      Example:
             build-index-RNAseq.sh -p 12 rsem-star GRCh38 Ensembl-GRCh38

When specifying ``hisat2``, ``build-index-RNAseq.sh`` downloads prebuilt indexes instead of building them to reduce the computational time.
Therefore ``build-index-RNAseq.sh`` allows the genome build shown in the help abobe for hisat2, while any genome data is acceptable for the other programs.

In default, ``build-index-RNAseq.sh`` considers chromosomes only. If you want to include all scaffolds, add ``-a`` option.


star.sh: execute STAR and RSEM
------------------------------------------------

.. code-block:: bash

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

- Output

    - mapfile for a genome (star/\*.Aligned.sortedByCoord.out.bam)
    - mapfile for genes (star/\*.Aligned.toTranscriptome.out.bam)
    - gene expression data (star/\*.genes.results)
    - transcript expression data (star/\*.isoforms.results)
    - mapping stats (log/star-\*.txt)

log example:

.. csv-table::

   "Sequenced","Uniquely mapped","(%)","Mapped to multiple loci","(%)","Mapped to too many loci","(%)","Unmapped (too many mismatches)","Unmapped (too short)","Unmapped (other)","chimeric reads","(%)","Splices total","Annotated","(%)","Non-canonical","(%)","Mismatch rate per base (%)","Deletion rate per base (%)","Insertion rate per base (%)"
   "29446992","27430449","93.15","1012811","3.44","5253","0.02","0%","3%","0%","0","0","18960488","18725703","98.76","30590","0.16","0.19","0.01","0.01"


rsem_merge.sh: merge expression data of multiple samples
------------------------------------------------------------------------------------------------

.. code-block:: bash

    rsem_merge.sh [-s <strings for sed>] <inputdirs> <prefix> <Ddir>
        <inputdirs>: directories of samples (should be quoted)
        <prefix>: prefix of output files
        <Ddir>: directory of index and gtf files
        Options:
            -s <strings for sed>: specify strings that you want to remove from sample labels (e.g., "HeLa_", multiple strings should be separated by spaces)
        Example:
            rsem_merge.sh "star/Ctrl1 star/Ctrl2 star/siCTCF1 star/siCTCF2" Matrix_edgeR/HEK293

- Output

    - gene expression data: \*.genes.<TPM|count>.txt
    - transcript expression data: \*.isoforms.<TPM|count>.txt
    - merged xlsx file: \*.xlsx


DESeq2.sh: differential expression analysis for two groups by DESeq2
------------------------------------------------------------------------------------------------

.. code-block:: bash

    DESeq2.sh [Options] <inputfile> <num of reps> <groupname> <species>
        <inputfile>: prefix of input matrix file
        <Ddir>: directory of gene annotation files
        <num of reps>: number of replicates (quated by ":")
        <group name>: labels of two groups compared (quated by ":")
        <species>: Species for the GO analysis [Human|Mouse|Rat|Fly|Celegans]
        Options:
            -l <float>: log2 fold change threshold (default: 1)
            -c <int>: column position for gene symbol (default: 1)
            -t <float>: FDR threshould for DEG identification (default: 0.05)
            -n <int>: number of top-ranked DEGs for GO analysis (default: 500)
            -k: Supply when the input file is generated by "kallisto_merge.sh" (default: "rsem_merge.sh")
        Example:
            DESeq2.sh star/Matrix 2:2 WT:KD Human

- Output

    - Matrix.\*.count.DESeq2.all.tsv ... list of all genes
    - Matrix.\*.count.DESeq2.DEGs.tsv ... list of all DEGs
    - Matrix.\*.count.DESeq2.upDEGs.tsv ... list of all upregulated DEGs
    - Matrix.\*.count.DESeq2.downDEGs.tsv ... list of all upregulated DEGs
    - Matrix.\*.count.DESeq2.xlsx ... xlsx file that include all .tsv files above
    - Matrix.\*.count.DEGs.bed ... BED file of DEGs
    - Matrix.\*.count.DEGs.bed6 ... BED6 file of DEGs that contain gene name, length and strand information

    - Matrix.\*.count.DESeq2.Dispersionplot.pdf ... Dispersion plot of log-scale gene expression before and after dispersion fitting
    - Matrix.\*.count.DESeq2.MAplot.pdf ... MA plot of all genes. Significantly differential genes are highlighted in red. "shrunken apeglm" removes the high variance of low expression genes.
    - Matrix.\*.count.DESeq2.Volcano.pdf ... Volcano plot of all genes. Top-ranked genes are labeled.
    - Matrix.\*.count.DESeq2.HighlyExpressedGenes.pdf ... Heatmap of top-ranked DEGs
    - Matrix.\*.count.DESeq2.sampleClustering.pdf ... Clustering results of sample-wide comparison
    - Matrix.\*.count.DESeq2.samplePCA.pdf ... PCA plot of samples based on gene expression level


edgeR.sh: differential expression analysis for two groups by edgeR
-----------------------------------------------------------------------------------------------

.. code-block:: bash

    edgeR.sh [Options] <inputfile> <num of reps> <groupname> <species>
        <inputfile>: prefix of input matrix file
        <Ddir>: directory of gene annotation files
        <num of reps>: number of replicates (quated by ":")
        <group name>: labels of two groups compared (quated by ":")
        <species>: [Human|Mouse|Rat|Fly|Celegans]
        Options:
            -t <float>: FDR threshould for DEG identification (default: 0.05)
            -n <int>: number of top-ranked DEGs for GO analysis (default: 500)
            -k: Supply whe the input file is generated by "kallisto_merge.sh" (default: "rsem_merge.sh")
        Example:
        edgeR.sh Matrix 2:2 WT:KD Human

- Output

    - Matrix.\*.count.edgeR.all.tsv ... list of all genes
    - Matrix.\*.count.edgeR.DEGs.tsv ... list of all DEGs
    - Matrix.\*.count.edgeR.upDEGs.tsv ... list of all upregulated DEGs
    - Matrix.\*.count.edgeR.downDEGs.tsv ... list of all downregulated DEGs
    - Matrix.\*.count.edgeR.xlsx ... xlsx file that include all .tsv files above
    - Matrix.\*.count.DEGs.bed ... BED file of DEGs
    - Matrix.\*.count.DEGs.bed6 ... BED6 file of DEGs that contain gene name, length and strand information

    - Matrix.\*.count.density.png ... Gene expression distribution (log scale)
    - Matrix.\*.count.QQplot.1stSample.pdf ... QQplot of the 1st sample
    - Matrix.\*.count.edgeR.BCV-MDS.pdf ... BCV and MDS plots for estimating variance among input samples
    - Matrix.\*.count.edgeR.MAplot.pdf ... MA plot of all genes. Significantly differential genes are highlighted in red. "shrunken apeglm" removes the high variance of low expression genes.
    - Matrix.\*.count.heatmap.0.01.png ... Heatmap of DEGs
    - Matrix.\*.count.samplesCluster.inDEGs.pdf ... Hierarchical tree of samples obtained the heatmap above
    - Matrix.\*.count.edgeR.Volcano.pdf ... Volcano plot of all genes. Top-ranked genes are labeled.
    - Matrix.\*.count.samplePCA.pdf ... PCA plot of samples based on gene expression level

- ``Matrix.\*.count.edgeR.\*.tsv`` contains the value fitted by the ``glmQLFit`` function in edgeR, which is then normalized by the total number of reads. It does not contain the variance among replicates. edgeR (and DESeq2) assumes no variance in the same group, so the fitted value will be the same.
- ``Matrix.\*.count.heatmap.0.01.png`` uses the normalized fitted values.

- Note:
    - While the previous version of ``edgeR.sh`` filtered genes with 0 expression in all samples, the current version uses the ``filterByExpr`` function provided by edgeR. This results in more genes being filtered than before, and the FDR value changes accordingly, so more genes become non-significant.
    - The current version allows ``-lfcthre`` if you want to filter DEGs by ``log2foldchange`` in addition to the FDR threshold. Setting ``-lfcthre=1`` will output only those genes that vary more than 2-fold (not strictly) between groups as DEGs.
    - Fixed an error on drawing heatmaps when the number of DEGs is zero.


check_stranded.sh
------------------------------------------------

In case that it is not clear whether the input samples are stranded or not, use ``check_stranded.sh`` for the quick check.

.. code-block:: bash

    check_stranded.sh [human|mouse] <fastq>

This command runs bowtie to map reads onto the mRNA sequences obtained from NCBI. If the samples are reverse-straned, the most reads will be mapped to the reverse strand.
If fifty-fifty, the samples are unstranded.


parsebowtielog2.pl
------------------------------------------------

``parsebowtielog2.pl`` parses the log file of bowtie2 and outputs the number of mapped reads. This script is useful to merge the stats for all samples into a single .tsv file. Add ``-p`` option if the input files are paired-end reads.

.. code-block:: bash

    parsebowtielog2.pl [--pair|-p] <file> <label>

csv2xlsx.pl
------------------------------------------------

This command merges csv/tsv files to a single xlsx file.


.. code-block:: bash

    csv2xlsx.pl -i file1.tsv -n tabname1 [-i file2.tsv -n tabname2 ...] -o output.xlsx
    Options:
          -d --delim=<str>: delimiter of input files (default:\t)
