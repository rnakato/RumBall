# Script to run GO analysis in tab delimited files using clusterProfiler
# Author: Eijy Nagai
# Last modification: October 6, 2022

# Necessary input/files names
# from DESeq2
# 1. HEK293.genes.count.DESeq2.upDEGs.tsv
# 2. HEK293.genes.count.DESeq2.downDEGs.tsv

# from edgeR
# 1. HEK293.genes.count.edgeR.DEGs.tsv
# 2. HEK293.genes.count.edgeR.downDEGs.tsv

# How to run
print.usage <- function() {
	cat('\nUsage: Rscript run_clusterProfiler.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -i=<input file>          , input file (DEG list either from edgeR or DEseq) \n',file=stderr())
	cat('      -n=<n>                   , number of DEGs to consider \n',file=stderr())
	cat('   OPTIONAL ARGUMENTS\n',file=stderr())
        cat('      -orgdb=<orgdb>           , OrgDb annotation. Choose org.Hs.eg.db org.Mm.eg.db  \n', file=stderr())
        cat('      -ont=<ont>               , One of "BP", "MF", and "CC" subontologies, or "ALL" for all three \n', file=stderr())
	cat('      -padjmethod=<padjmethod> ,  "BH", "holm", "hochberg", "hommel", "bonferroni", "BY", "fdr", "none" \n',file=stderr())
	cat('      -p=<float>               , threshold for FDR (default: 0.01) \n',file=stderr())
	cat('   OUTPUT ARGUMENTS\n',file=stderr())
	cat('      -o=<output>              , prefix of output file \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly = T)
nargs = length(args);
minargs = 1;
maxargs = 6;
if (nargs < minargs | nargs > maxargs) {
        print.usage()
        q(save="no",status=1)
}

nrowname <- 1
ncolskip <- 0
orgdb <- "org.Hs.eg.db"
ont <- "BP"
padjmethod <- "BH"
p <- 0.05
n <- 500

for (each.arg in args) {
    if (grepl('^-i=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            filename <- arg.split[2]
        }
        else { stop('No input file name provided for parameter -i=')}
    }
    else if (grepl('^-n=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            n <- as.numeric(arg.split[2])
        }
        else { stop('No value provided for parameter -n=')}
    }
    else if (grepl('^-orgdb=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            orgdb <- arg.split[2]
        }
        else { stop('No value provided for parameter -orgdb=')}
    }
    else if (grepl('^-ont=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            ont <- arg.split[2]
        }
        else { stop('No value provided for parameter -ont=')}
    }
    else if (grepl('^-padjmethod=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            padjmethod <- arg.split[2]
        }
        else { stop('No value provided for parameter -padjmethod=')}
    }
    else if (grepl('^-p=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            p <- as.numeric(arg.split[2])
        }
        else { stop('No value provided for parameter -p=')}
    }
    else if (grepl('^-o=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            output <- arg.split[2]
        }
        else { stop('No output file name provided for parameter -o=')}
    }
}

# Get sample name and if it was made by DESeq2 or EdgeR
tmp <- strsplit(filename, "[.]")[[1]][1]
sample <- strsplit(tmp, "_")[[1]][2]

# Print objects
filename
sample
n
orgdb
ont
padjmethod
p
output

suppressPackageStartupMessages(library("clusterProfiler"))
suppressPackageStartupMessages(library('org.Mm.eg.db'))
suppressPackageStartupMessages(library('org.Hs.eg.db'))
suppressPackageStartupMessages(library('org.Rn.eg.db'))
suppressPackageStartupMessages(library('org.Dm.eg.db'))
suppressPackageStartupMessages(library('org.Ce.eg.db'))
suppressPackageStartupMessages(library("enrichplot"))
suppressPackageStartupMessages(library("AnnotationHub"))
suppressPackageStartupMessages(library("ggplot2"))
suppressPackageStartupMessages(library("dplyr"))

# Check if input and output exist.
#outdir <- "GO_results"
#if (!file.exists(outdir)) {
#  cat("Output directory does not exist, creating...")
#  dir.create(file.path(outdir))
#  cat(" done!\n")
#}

# deleting previous outputfile
#Check its existence
#if (file.exists(paste0(outdir,"/",output,"_top",n,".pdf")))
if (file.exists(paste0(output,"_top",n,".pdf")))
    #Delete file if it exists
    #file.remove(file=paste0(outdir,"/",output,"_top",n,".pdf"))
    file.remove(file=paste0(output,"_top",n,".pdf"))


# Read in each file separated
data <-read.csv(file = filename, sep = "\t", header = TRUE)



# Order files based on the FDR or P-adjust score and then Fold Change
# Determine whether the file is processed by EdgeR or DESeq2
if (strsplit(sample, "/")[[1]][1] == "deseq2"){
    data2 <- data %>%
         as.data.frame() %>%
         arrange(padj) %>%
         filter(padj < 0.05) %>%
         arrange(desc(log2FoldChange))
} else{
    data2 <- data %>%
         as.data.frame() %>%
         arrange(FDR) %>%
         filter(FDR < 0.05) %>%
         arrange(desc(logFC))
}
#data2



# Select just top X genes
deg.list <- data2[1:n,1]  #using EmsemblID, set to 2 for Symbol but some genes might be missing
#print(deg.list)
#print(keytypes(org.Hs.eg.db))



# Convert the symbols to ENTREZID (necessary for clusterprofiler)
# If the IDs are in different format, need to adjust properly or skip the process
convertID <- function(deg.list){
    convertedIDs <- bitr(deg.list,
                         fromType = "ENSEMBL",
                         toType   = "ENTREZID",
                         OrgDb    = orgdb,
                         drop     = TRUE)
    return(convertedIDs$ENTREZID)
    }

deg.list2 <- convertID(deg.list)

ego <- enrichGO(gene          = deg.list2,
                OrgDb         = orgdb,
                keyType       = 'ENTREZID',
                ont           = ont,
                pAdjustMethod = padjmethod,
                pvalueCutoff  = p,
                #qvalueCutoff  = p,
                readable = TRUE)

head(ego)

if (length(ego$Count) != 0){

    # Find the longest string in the Description column

    #ego <- head(ego, 10)

    df1 <- as.data.frame(ego$Description)
    max_lenght <- as.numeric(lapply(df1, function(x) max(nchar(x))))

    #plot.width = max(max_lenght/9, 7)
    #print(plot.width)
    plot.width = 7
    plot.height = 4


    #options(repr.plot.width = plot.width, repr.plot.height = plot.height)
    fig <- mutate(ego, qscore = -log(p.adjust, base=10)) %>%
              barplot(x = "qscore") +
              ggtitle(paste0("GO enrichment of ",sample)) +
              theme(text = element_text(size=8))
#    ggsave(fig, file=paste0(outdir,"/",output,"_top",n,".pdf"), width = plot.width, height = plot.height)
    ggsave(fig, file=paste0(output,"_top",n,".pdf"), width = plot.width, height = plot.height)

} else if (length(ego$Count) == 0){

    print('No GO terms enriched for the sets of genes submitted. Skipping plot...')

}

print('GO enrichment analysis done.')
