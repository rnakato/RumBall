# Script to run GO analysis in tab delimited files using GProfiler2
# Author: Eijy Nagai
# Last modification: October 13, 2022

# Necessary input/files example
# from DESeq2
# 1. HEK293.genes.count.DESeq2.upDEGs.tsv
# 2. HEK293.genes.count.DESeq2.downDEGs.tsv

# from edgeR
# 1. HEK293.genes.count.edgeR.DEGs.tsv
# 2. HEK293.genes.count.edgeR.downDEGs.tsv


# How to run
print.usage <- function() {
    cat('\nUsage: Rscript run_gprofiler2.R <options>\n',file=stderr())
    cat('   MANDATORY ARGUMENTS\n',file=stderr())
    cat('      -i_up=<input file upregulated>       , input file (upDEG list either from edgeR or DEseq) \n',file=stderr())
    cat('      -i_down=<input file downregulated>   , input file (downDEG list either from edgeR or DEseq) \n',file=stderr())
    cat('      -n=<n>                               , number of DEGs to consider \n',file=stderr())
    cat('      -org=<org>                           , Organism <hsapiens, mmusculus> \n', file=stderr())
    cat('   OPTIONAL ARGUMENTS\n',file=stderr())
    cat('      -tool=<tool>                         , [deseq2|edger] (default:deseq2) \n', file=stderr())
    cat('   OUTPUT ARGUMENTS\n',file=stderr())
    cat('      -o=<output>                          , prefix of output file \n',file=stderr())
    cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly = T)
nargs = length(args);
minargs = 5;
maxargs = 6;
if (nargs < minargs | nargs > maxargs) {
        print.usage()
        q(save="no",status=1)
}

tool <- "deseq2"

for (each.arg in args) {
    if (grepl('^-i_up=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            updeg <- arg.split[2]
        }
        else { stop('No input file name provided for parameter -i_up=')}
    }
    if (grepl('^-i_down=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            downdeg <- arg.split[2]
        }
        else { stop('No input file name provided for parameter -i_down=')}
    }
    else if (grepl('^-n=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            n <- as.numeric(arg.split[2])
        }
        else { stop('No value provided for parameter -n=')}
    }
    else if (grepl('^-org=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            org <- arg.split[2]
        }
        else { stop('No value provided for parameter -org=')}
    }
    else if (grepl('^-tool=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            tool <- arg.split[2]
        }
        else { stop('No value provided for parameter -ont=')}
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
tmp <- strsplit(updeg, "[.]")[[1]][1]
tmp <- strsplit(tmp, "_")[[1]][2]
sample <- strsplit(tmp, "/")[[1]][2]
#tool <- strsplit(tmp, "/")[[1]][1]

# check the variables
sample
tool
updeg
downdeg
n
org
output


##########################
#  Load the libraries
suppressPackageStartupMessages(library(gprofiler2))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(clusterProfiler))
suppressPackageStartupMessages(library(enrichplot))
suppressPackageStartupMessages(library(DOSE))
suppressPackageStartupMessages(library(dplyr))

# Check if input and output exist.
#outdir <- "GO_results"
#if (!file.exists(outdir)) {
#  cat("Output directory does not exist, creating...")
#  dir.create(file.path(outdir))
#  cat(" done!\n")
#}

# deleting previous outputfile
#Check its existence
if (file.exists(paste0(output,"_top",n,".pdf"))){
    #Delete file if it exists
    file.remove(file=paste0(output,"_top",n,".pdf"))
}



# Order files based on the FDR or P-adjust score and then Fold Change
# Determine whether the file is processed by EdgeR or DESeq2
preprodata <- function(sample, exprtable){
    if (tool == "deseq2"){
        exprtable_filt <- exprtable %>%
            as.data.frame() %>%
            arrange(padj) %>%
            filter(padj < 0.05) %>%
            arrange(desc(log2FoldChange))
    } else{
        exprtable_filt <- exprtable %>%
            as.data.frame() %>%
            arrange(FDR) %>%
            filter(FDR < 0.05) %>%
            arrange(desc(logFC))
    }
    return(exprtable_filt)
}



# Read in UP regulated DEG file
data_up <- read.csv(file = updeg, sep = "\t", header = TRUE)
data_up_prepro <- preprodata(sample, data_up)
deg.list_up <- data_up_prepro[,1]  #using EmsemblID, set 2 for Symbol but some genes might be missing
deg.list_up_dedup <- deg.list_up[!duplicated(deg.list_up)]
#deg.list_up_final <- gconvert(deg.list_up_dedup[1:n])
deg.list_up_final <- gconvert(deg.list_up_dedup[1:n], organism = org)
#print(head(deg.list_up_final))


# Read in DOWN regulated DEG file
data_down <- read.csv(file = downdeg, sep = "\t", header = TRUE)
data_down_prepro <- preprodata(sample, data_down)
deg.list_down <- data_down_prepro[,1]  #using EmsemblID, set 2 for Symbol but some genes might be missing
deg.list_down_dedup <- deg.list_down[!duplicated(deg.list_down)]
#deg.list_down_final <- gconvert(deg.list_down_dedup[1:n])
deg.list_down_final <- gconvert(deg.list_down_dedup[1:n], organism = org)
                                        #print(head(deg.list_down_final))

# g:GOSt tool that performs over-representation analysis using hypergeometric test.
multi_gp <- gost(list("up-regulated" = deg.list_up_final, "down-regulated" = deg.list_down_final), organism = org, multi_query = FALSE, evcodes = TRUE)
#head(multi_gp$result)

# modify the g:Profiler data frame
gp_mod <- multi_gp$result[,c("query", "source", "term_id",
                      "term_name", "p_value", "query_size",
                      "intersection_size", "term_size",
                      "effective_domain_size", "intersection")]


gp_mod$GeneRatio <- paste0(gp_mod$intersection_size, "/", gp_mod$query_size)
gp_mod$BgRatio = paste0(gp_mod$term_size, "/", gp_mod$effective_domain_size)

names(gp_mod) <- c("Cluster", "Category", "ID", "Description", "p.adjust",
                  "query_size", "Count", "term_size", "effective_domain_size",
                  "geneID", "GeneRatio", "BgRatio")

gp_mod$geneID = gsub(",", "/", gp_mod$geneID)
#row.names(gp_mod) <- gp_mod$ID

# define as compareClusterResult object
gp_mod_cluster <- new("compareClusterResult", compareClusterResult = gp_mod)

# define as enrichResult object
gp_mod_ordered <- gp_mod %>%
                    as.data.frame() %>%
                    filter(Category == "GO:BP") %>%
                    group_by(Cluster) %>%
                    slice_min(order_by = p.adjust, n = 5)
gp_mod_enrich <- new("enrichResult", result = gp_mod_ordered)



##########################
# Plots
##########################

# Manhattan plot
p1 <- gostplot(multi_gp, interactive = FALSE)
publish_gostplot(p1)
ggsave(p1, file=paste0(output,"_", tool, "_p1_top",n,".pdf"))


# blarplot of GOs
p2 <- barplot(gp_mod_enrich, showCategory = 10, font.size = 14) +
              ggplot2::facet_grid(~ Cluster) +
              ggplot2::ylab("Intersection size") +
              ggtitle(paste0("GO: Biological process enriched terms for the top ",n," genes" )) +
              theme(plot.title = element_text(hjust = 0.5, size = 16)) +
              theme(strip.text.x = element_text(size = 12))
ggsave(p2, file=paste0(output,"_", tool,"_p2_top",n,".pdf") , width = 12, height = 5)


cat('Process finished! \n')
