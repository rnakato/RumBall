for id in SRR710092 SRR710093 SRR710094 SRR710095
do
    singularity exec --bind /work,/work2 /work/SingularityImages/SRAtools.3.0.0.sif fastq-dump $id --split-files
done

pigz *.fastq
