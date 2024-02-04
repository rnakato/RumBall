================================================================
RumBall
================================================================

**RumBall** is a RNA-seq analysis pipeline with Docker.
The latest version of **RumBall** (v0.7.0) internally uses the tools.

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
