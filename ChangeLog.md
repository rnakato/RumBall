# Changelog

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
