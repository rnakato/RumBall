Other examples
=====================


Analysis with RSEM-bowtie2
--------------------------------------------------

STAR requires large memory for mapping. Bowtie2 requires less memory with comparable mapping accuracy. 
Here we show the example using Bowtie2.

.. code-block:: bash

    # make index for bowtie2-RSEM
    build=GRCh38  # specify the build (Ensembl) that you need
    Ddir=Ensembl-$build/
    ncore=12  # number of CPUs 
    build-index.sh -p $ncore rsem-bowtie2 $build $Ddir


