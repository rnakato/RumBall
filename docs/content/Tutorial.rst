Tutorial
=====================

This page describes the tutorial how to get the results from FASTQ files.
The sample scripts for human, mouse and `S. cerevisiae` are also available at `RumBall GitHub <https://github.com/rnakato/RumBall/tree/main/tutorial>`_.

.. note::

   | This tutorial assumes using the **RumBall** singularity image (``rumball.sif``). Please add ``singularity exec rumball.sif`` before each command below.
   | Example: ``singularity exec rumball.sif download_genomedata.sh``

Get data
------------------------

Here we use four mRNA-seq samples of HEK293 cells (siCTCF and control from `Zuin et al., PNAS, 2014 <https://pubmed.ncbi.nlm.nih.gov/24335803/>`_):

.. code-block:: bash

    mkdir -p fastq
    for id in SRR710092 SRR710093 SRR710094 SRR710095
    do
        fastq-dump --gzip $id --split-files -O fastq
    done

Then download and generate the reference dataset including genome, gene annotation and index files.
**RumBall** contains several scripts to do that:

.. code-block:: bash

    build=GRCh38  # specify the build (Ensembl) that you need
    Ddir=Ensembl-$build/
    mkdir -p log

    # Download genome and gtf
    download_genomedata.sh $build $Ddir 2>&1 | tee log/Ensembl-$build

    # make index for STAR-RSEM
    ncore=12 # number of CPUs
    build-index.sh -p $ncore rsem-star $build $Ddir


Check Strandedness
--------------------------------------------------

If the strandedness of RNA-seq data is not clear, you can briefly check by ``check_stranded.sh`` command:


.. code-block:: bash

    $ check_stranded.sh human fastq/SRR710092_1.fastq.gz
    # reads processed: 56830606
    # reads with at least one alignment: 27787970 (48.90%)
    # reads that failed to align: 29042636 (51.10%)
    Reported 27787970 alignments
     540264 +
    27247706 -

In this example, majority of reads were mapped on - strand, so this RNA-seq is stranded.


Mapping reads by STAR
--------------------------------------------------

**RumBall** allows STAR, bowtie2, kallisto and salmon for mapping. Here we use STAR. The reads are then parsed by RSEM:

.. code-block:: bash

    Ddir=Ensembl-GRCh38
    mkdir -p log
    star.sh paired HEK293_Control_rep1 fastq/SRR710092_1.fastq.gz fastq/SRR710092_2.fastq.gz $Ddir reverse > log/star.sh.HEK293_Control_rep1
    star.sh paired HEK293_Control_rep2 fastq/SRR710093_1.fastq.gz fastq/SRR710093_2.fastq.gz $Ddir reverse > log/star.sh.HEK293_Control_rep2
    star.sh paired HEK293_siCTCF_rep1  fastq/SRR710094_1.fastq.gz fastq/SRR710094_2.fastq.gz $Ddir reverse > log/star.sh.HEK293_siCTCF_rep1
    star.sh paired HEK293_siCTCF_rep2  fastq/SRR710095_1.fastq.gz fastq/SRR710095_2.fastq.gz $Ddir reverse > log/star.sh.HEK293_siCTCF_rep2

Of course you can also use a shell loop:

.. code-block:: bash

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


Differential analysis
--------------------------------------------------

``rsem_merge.sh`` merges the RSEM output of all samples.
The generated matrix can be applied to DESeq2 or edgeR to identify differentially expressed genes between two groups:

.. code-block:: bash

    Ctrl="star/HEK293_Control_rep1 star/HEK293_Control_rep2"
    siCTCF="star/HEK293_siCTCF_rep1 star/HEK293_siCTCF_rep2"
    # For DESeq2
    mkdir -p Matrix_deseq2
    rsem_merge.sh "$Ctrl $siCTCF" Matrix_deseq2/HEK293 $Ddir
    DESeq2.sh Matrix_deseq2/HEK293 2:2 Control:siCTCF Human

    # For edgeR
    mkdir -p Matrix_edgeR
    rsem_merge.sh "$Ctrl $siCTCF" Matrix_edgeR/HEK293 $Ddir
    edgeR.sh Matrix_edgeR/HEK293 2:2 Control:siCTCF Human

From ``v0.3.0``, ``DESeq2.sh`` and ``edgeR.sh`` also implement gene onthology (GO) analysis
using `ClusterProfiler <https://bioconductor.org/packages/clusterProfiler/>`_ and `gprofiler2 <https://cran.r-project.org/web/packages/gprofiler2/vignettes/gprofiler2.html>`_. 
They use top-ranked 500 upregulated/downregulated DEGs for the GO analysis. Use `-n` option the change the gene number.