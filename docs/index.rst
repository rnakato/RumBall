================================================================
RumBall
================================================================

**RumBall** is a RNA-seq analysis pipeline with Docker.
The latest version of **RumBall** (v0.6.0) internally uses the tools.

- Mapping tools
   - BWA version 0.7.17
   - Bowtie version 1.3.1
   - Bowtie2 version 2.4.5
   - chromap version 0.2.4

- Mapping tools for RNA-seq
   - STAR v2.7.10a
   - salmon v1.7.0
   - hisat v2.2.1
   - kallisto v0.46.1

- RNA-seq tools
   - RSEM v1.3.3
   - edgeR v3.38.1
   - DESeq2 v1.36.0
   - stringtie v2.2.1
   - ballgown v2.18.0
   - sleuth v0.30.0

- Gene onthology (GO) analysis tools
   - ClusterProfiler v4.4.4
   - gprofiler2 v0.2.1

- Utility tools
   - SRAtoolkit version 3.0.2
   - SAMtools version 1.17
   - BEDtools version 2.30.0


Contents:
---------------

.. toctree::
   :numbered:
   :glob:
   :maxdepth: 1

   content/Install
   content/Tutorial
   content/kallisto
   content/Commands
