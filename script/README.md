## Scripts for RNA-seq analysis
---
### csv2xlsx.pl
merge csv/tsv files to a single xlsx file

    csv2xlsx.pl -i file1.tsv -n tabname1 [-i file2.tsv -n tabname2 ...] -o output.xlsx
    Options:
          -d --delim=<str>: delimiter of input files (default:\t)

---
## RNA-seq pipeline
Command example:

    for prefix in CDLS1 CDLS2 WT1 WT2; do
       star.sh paired $prefix "fastq/${prefix}_R1.fq.gz fastq/${prefix}_R2.fq.gz" Ensembl GRCh38 0
    done
    
    rsem_merge.sh "WT1 WT2 CDLS1 CDLS2" Matrix.CdLS Ensembl GRCh38 "2015_001"
    edgeR.sh Matrix.CdLS Ensembl GRCh38 2:2 0.05

### star.sh: execute STAR and RSEM
#### Usage

    star.sh <single|paired> <output prefix> <fastq> <Ensembl|UCSC> <build> <--forward-prob>

For `--forward-prob`, supply 0 for stranded RNA-seq and 0.5 for unstranded RNA-seq.

Output:
* mapfile for a genome (star/*.Aligned.sortedByCoord.out.bam)
* mapfile for genes (star/*.Aligned.toTranscriptome.out.bam)
* gene expression data (star/*.genes.results)
* transcript expression data (star/*.isoforms.results)
* mapping stats (log/star-*.txt)

log example:

|Sequenced	|Uniquely mapped|	(%)	|Mapped to multiple loci|	(%)|	Mapped to too many loci|	(%)|	Unmapped (too many mismatches)	|Unmapped (too short)	|Unmapped (other)	|chimeric reads|	(%)	|Splices total	|Annotated	|(%)	|Non-canonical	|(%)	|Mismatch rate per base (%)|	Deletion rate per base (%)	|Insertion rate per base (%)|
----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----
|29446992	|27430449	|93.15	|1012811	|3.44	|5253	|0.02	|0%|	3%	|0%	|0	|0	|18960488	|18725703	|98.76	|30590	|0.16	|0.19	|0.01	|0.01|

### rsem_merge.sh: merge expression data of multiple samples

    rsem_merge.sh <files> <output> <Ensembl|UCSC> <build> <strings for removal>

Output:
* gene expression data: *.genes.<TPM|count>.<build>.txt
* transcript expression data: *.isoforms.<TPM|count>.<build>.txt
* merged xlsx file: *.<build>.xlsx 

### edgeR.sh: differential expression analysis for two groups by edgeR

    edgeR.sh [-a] <Matrix> <Ensembl|UCSC> <build> <num of reps> <groupname>  <FDR>

Output
* merged xlsx: *.<genes|isoforms>.count.<build>.edgeR.xlsx
* BCV/MDS plot: *.<genes|isoforms>.count.<build>.BCV-MDS.pdf
* MA plot:  *.<genes|isoforms>.count.<build>.MAplot.pdf

* DEGのリストからは1kbpより短い遺伝子は除かれます。また、出力されるのはprotein_coding、antisense, lincRNAのみです。ALLには全て含まれます。
* DEGにこれらの遺伝子を含めたい場合は-aオプションを指定します。
