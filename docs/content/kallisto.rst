Analysis with kallisto
===============================

RumBall also supports kallisto for RNA-seq analysis. The following example shows how to run kallisto on the same samples in :doc:`Tutorial`.


Mapping reads by kallisto
--------------------------------

Make index for kallisto:

.. code-block:: bash

    build=GRCh38  # specify the build that you need
    Ddir=Ensembl-$build/
    ncore=12  # number of CPUs
    build-index-RNAseq.sh -p $ncore kallisto $build $Ddir

Run kallisto:

.. code-block:: bash

    ID=("SRR710092" "SRR710093" "SRR710094" "SRR710095")
    NAME=("HEK293_Control_rep1" "HEK293_Control_rep2" "HEK293_siCTCF_rep1" "HEK293_siCTCF_rep2")

    index=$Ddir/kallisto-indexes/genome
    ncore=12  # number of CPUs
    mkdir -p log
    for ((i=0; i<${#ID[@]}; i++))
    do
        echo ${NAME[$i]}
        fq1=fastq/${ID[$i]}_1.fastq.gz
        fq2=fastq/${ID[$i]}_2.fastq.gz
        kallisto.sh -p $ncore ${NAME[$i]} "$fq1 $fq2" $Ddir reverse
    done

Then you can merge the output of kallisto to make a single count matrix using ``kallisto_merge.sh``:

.. code-block:: bash

    s=""
    for ((i=0; i<${#ID[@]}; i++))
    do
        s="$s kallisto/${NAME[$i]}/abundance.tsv"
    done

    mkdir -p Matrix_kallisto
    kallisto_merge.sh "$s" Matrix_kallisto/HEK293 $Ddir


Differential analysis
--------------------------------

The diffential analysis step is the same with the STAR example in :doc:`Tutorial`.

.. code-block:: bash

    Ctrl="kallisto/HEK293_Control_rep1 kallisto/HEK293_Control_rep2"
    siCTCF="kallisto/HEK293_siCTCF_rep1 kallisto/HEK293_siCTCF_rep2"

    # For DESeq2
    mkdir -p Matrix_edgeR_kallisto
    rsem_merge.sh "$Ctrl $siCTCF" Matrix_edgeR_kallisto/HEK293 $Ddir
    DESeq2.sh Matrix_edgeR_kallisto/HEK293 2:2 Control:siCTCF Human

    # For edgeR
    mkdir -p Matrix_deseq2_kallisto
    rsem_merge.sh "$Ctrl $siCTCF" Matrix_deseq2_kallisto/HEK293 $Ddir
    edgeR.sh Matrix_deseq2_kallisto/HEK293 2:2 Control:siCTCF Human

.. note::

    It is recommended to use `sleuth <https://pachterlab.github.io/sleuth/>`_ for the differential analysis of the kallisto output instead of edgeR and DESeq2. See the `sleuth walkthroughs <https://pachterlab.github.io/sleuth/walkthroughs>`_ for more details.