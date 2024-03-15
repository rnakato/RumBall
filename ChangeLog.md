# Changelog

## 0.7.3 (2024-3-7)
  - Added `mptable.UCSC.T2T.28mer.flen150.txt` and `mptable.UCSC.T2T.36mer.flen150.txt` in `SSP/data/mptable`.
  - Added the ideogram file for the T2T genome in `DROMPAplus/data/ideogram`.
  - Modified `download_genomedata.sh` to download the reference file of the T2T genome.
  - Updated chromap from v0.2.5 to v0.2.6

## 0.7.2 (2024-3-3)
  - Fixed a bug in `download_genomedata.sh` that did not download the genome data correctly.

## 0.7.1 (2024-02-21)
- Install MS core fonts (ttf-mscorefonts-installer)
  
## 0.7.0 (2024-02-03)
- Added user ubuntu
- Installed `sudo`
- Updated Miniconda from Python 3.9 to Python 3.10
- Updated STAR from v2.7.10a to v2.7.11b
- Updated salmon from from v1.7.0 to v1.10.0
- Updated Bowtie2 from v2.4.5 to v2.5.3
- Updated chromap from v0.2.4 to v0.2.5
- Changed WORKDIR from /opt to /home/ubuntu

## 0.6.0 (2024-01-16)
- Modified the scripts for the kallisto analysis.
- Added the `-k` option to DESeq2.sh to allow the kallisto output.
- Added the `-noannotation` option to DESeq2.R.
- Updated the Manual and added the tutorial of kallisto.

## 0.5.2 (2024-01-13)
- Bug Fix in DESeq2.sh and DESeq2.R that the option is not passed correctly
- Changed the gene name in `HighlyExpressedGenes.pdf` of DESeq2 analysis from Ensembl ID to gene symbol.
- Added a sample script (bowtie2.sh) for using bowtie2 for mapping in the `tutorial/` directory.
- Added `parsebowtielog2.pl` that parses the log file of bowtie2 and outputs the number of mapped reads.
- Updated the Manual and added the tutorial of RSEM-bowtie2.

## 0.5.1 (2023-12-30)
- Enable Docker scripts to write files in `/work/`
- Reduce default memory allocation from 96G to 48G
- Remove g:profiler2 report in favor of ClusterProfiler for GO enrichment

## 0.5.0 (2023-12-21)
- Added OpenBLAS-0.3.24
- Updated bedtools from v2.30.0 to v2.31.0

## 0.4.4 (2023-07-16)
- Updated `download_genomedata.sh` for S.pombe
- Updated `build-index-RNAseq.sh` for S.pombe

## 0.4.3 (2023-05-11)
- Removed /root/.cpanm/work directory

## 0.4.2 (2023-04-23)
- Changed the base image from rnakato/database to rnakato/mapping (to simplify installation)
- Changed the script nake ``build-index.sh`` to ``build-index-RNAseq.sh``

## 0.4.1 (2023-02-16)
- While the previous version of ``edgeR.sh`` filtered genes with 0 expression in all samples, the current version uses the ``filterByExpr`` function provided by edgeR. This results in more genes being filtered than before, and the FDR value changes accordingly, so more genes become non-significant.
- The current version allows ``-lfcthre`` if you want to filter DEGs by ``log2foldchange`` in addition to the FDR threshold. Setting ``-lfcthre=1`` will output only those genes that vary more than 2-fold (not strictly) between groups as DEGs.
- Fixed an error on drawing heatmaps when the number of DEGs is zero.

## 0.3.0 (2022-11-2)
- convert_genename_fromgtf.pl: add Ensembl id to "genename" column if the gene name is not provided in the input gtf file
- Added GO analysis using clusterProfiler and gprofiler

## 0.2.0
- Public release
- Updated Manual

## 0.1.0
- First commit
