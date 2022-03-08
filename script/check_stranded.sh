Ddir=/work/Database
index_mRNA_human=$Ddir/bowtie-indexes/NCBI-H_sapiens-allrna.NM
index_mRNA_mouse=$Ddir/bowtie-indexes/NCBI-M_musculus-allrna.NM

# check stranded RNA (human)
bowtie $index_mRNA_human <(zcat $1) -p12 | cut -f2 | sort | uniq -c
# check stranded RNA (mouse)
#bowtie $index_mRNA_mouse <(zcat $1) -p12 | cut -f2 | sort | uniq -c
