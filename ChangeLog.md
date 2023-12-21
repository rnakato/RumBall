# Changelog

## 0.5.0 (2023-12-21)
    - Add OpenBLAS-0.3.24
    - Update bedtools from v2.30.0 to v2.31.0

## 0.4.4 (2023-07-16)
- Update `download_genomedata.sh` for S.pombe
- Update `build-index-RNAseq.sh` for S.pombe

## 0.4.3 (2023-05-11)
- Remove /root/.cpanm/work directory

## 0.4.2 (2023-04-23)
- Change the base image from rnakato/database to rnakato/mapping (to simplify installation)
- Change the script nake ``build-index.sh`` to ``build-index-RNAseq.sh``

## 0.4.1 (2023-02-16)
- While the previous version of ``edgeR.sh`` filtered genes with 0 expression in all samples, the current version uses the ``filterByExpr`` function provided by edgeR. This results in more genes being filtered than before, and the FDR value changes accordingly, so more genes become non-significant.
- The current version allows ``-lfcthre`` if you want to filter DEGs by ``log2foldchange`` in addition to the FDR threshold. Setting ``-lfcthre=1`` will output only those genes that vary more than 2-fold (not strictly) between groups as DEGs.
- Fixed an error on drawing heatmaps when the number of DEGs is zero.

## 0.3.0 (2022-11-2)
- convert_genename_fromgtf.pl: add Ensembl id to "genename" column if the gene name is not provided in the input gtf file
- add GO analysis using clusterProfiler and gprofiler

## 0.2.0
- Public release
- Update Manual

## 0.1.0
- First commit
