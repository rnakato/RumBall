Installation
================

Docker image of **RumBall** (based on Ubuntu 22.04) is available at `DockerHub <https://hub.docker.com/r/rnakato/rumball>`_.
This image contains various tools for RNA-seq analysis as below:

- Mapping tools
   - `BWA <https://bio-bwa.sourceforge.net/>`_ v0.7.17
   - `Bowtie <https://bowtie-bio.sourceforge.net/manual.shtml>`_ v1.3.1
   - `Bowtie2 <https://bowtie-bio.sourceforge.net/bowtie2/index.shtml>`_ v2.5.3
   - `chromap <https://github.com/haowenz/chromap>`_ v0.2.5

- Mapping tools for RNA-seq
   - `STAR <https://github.com/alexdobin/STAR>`_ 2.7.11b
   - `salmon <https://combine-lab.github.io/salmon/>`_ v1.10.0
   - `HISAT2 <https://daehwankimlab.github.io/hisat2/>`_ v2.2.1
   - `kallisto <https://github.com/pachterlab/kallisto>`_ v0.46.1

- Gene expression estimation
   - `RSEM <https://github.com/deweylab/RSEM>`_ v1.3.3
   - `StringTie <https://ccb.jhu.edu/software/stringtie/>`_ v2.2.1

- Differential expression analysis
   - `edgeR <https://bioconductor.org/packages/release/bioc/html/edgeR.html>`_ v3.38.1
   - `DESeq2 <https://bioconductor.org/packages/release/bioc/html/DESeq2.html>`_ v1.36.0
   - `ballgown <https://bioconductor.org/packages/release/bioc/html/ballgown.html>`_ v2.18.0
   - `sleuth <https://github.com/pachterlab/sleuth>`_ v0.30.0

- Gene onthology (GO) analysi
   - `ClusterProfiler <https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html>`_ v4.4.4
   - `gprofiler2 <https://cran.r-project.org/web/packages/gprofiler2/vignettes/gprofiler2.html>`_ v0.2.1

- Quality assessment
   - `FastQC <https://www.bioinformatics.babraham.ac.uk/projects/fastqc/>`_ v0.11.9

- Utility tools
   - `SRAtoolkit <https://github.com/ncbi/sra-tools>`_ v3.0.10
   - `SAMtools <http://www.htslib.org/>`_ v1.19.2
   - `BEDtools <https://bedtools.readthedocs.io/en/latest/>`_ v2.31.0


Docker
++++++++++++++

To use the docker command, type:

.. code-block:: bash

    # Pull docker image
    docker pull rnakato/rumball

    # Container login
    docker run --rm -it rnakato/rumball /bin/bash
    # Execute a command
    docker run -it --rm rnakato/rumball <command>

- user:password
    - ubuntu:ubuntu

Singularity
+++++++++++++++++++++++

Singularity is the alternative way to use the docker image.
With this command you can build the singularity file (.sif) of RumBall:

.. code-block:: bash

   singularity build rumball.sif docker://rnakato/rumball

Instead, you can download the RumBall singularity image from our `Dropbox <https://www.dropbox.com/scl/fo/lptb68dirr9wcncy77wsv/h?rlkey=whhcaxuvxd1cz4fqoeyzy63bf&dl=0>`_ (We use singularity version 3.8.5).

Then you can run RumBall with the command:

.. code-block:: bash

   singularity exec rumball.sif <command>

Singularity will automatically mount the current directory. If you want to access the files in the other directory, use the ``--bind`` option, for instance:

.. code-block:: bash

   singularity exec --bind /work rumball.sif <command>

This command mounts the ``/work`` directory.