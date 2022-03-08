# https://bioconductor.org/packages/release/bioc/vignettes/DESeq2/inst/doc/DESeq2.html

print.usage <- function() {
	cat('\nUsage: Rscript DESeq2.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -i=<input file>  , input file (RSEM gene/transcript file, estimated count) \n',file=stderr())
	cat('      -n=<num1>:<num2> , num of replicates for each group \n',file=stderr())
	cat('   OPTIONAL ARGUMENTS\n',file=stderr())
	cat('      -nrowname=<int> , row name (default: 1) \n',file=stderr())
    cat('      -ncolskip=<int> , colmun num to be skiped (default: 0) \n',file=stderr())
	cat('      -gname=<name1>:<name2> , name of each group \n',file=stderr())
	cat('      -p=<float>      , threshold for FDR (default: 0.01) \n',file=stderr())
	cat('   OUTPUT ARGUMENTS\n',file=stderr())
	cat('      -o=<output> , prefix of output file \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly = T)
nargs = length(args);
minargs = 1;
maxargs = 8;
if (nargs < minargs | nargs > maxargs) {
	print.usage()
	q(save="no",status=1)
}

gname1 <- "groupA"
gname2 <- "groupB"
p <- 0.01
nrowname <- 1
ncolskip <- 0

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
            sep.vals <- arg.split[2]
            sep.vals.split <- strsplit(sep.vals,':',fixed=TRUE)[[1]]
            if (length(sep.vals.split) != 2) {
                stop('must be specified as -n=<num1>:<num2>')
            } else {
                if (any(is.na(as.numeric(sep.vals.split)))) { # check that sep vals are numeric
                    stop('must be numeric values')
                }
                num1 <- as.numeric(sep.vals.split[1])
                num2 <- as.numeric(sep.vals.split[2])
            }
        }
        else { stop('No value provided for parameter -n=')}
    }
    else if (grepl('^-gname=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            sep.vals <- arg.split[2]
            sep.vals.split <- strsplit(sep.vals,':',fixed=TRUE)[[1]]
            if (length(sep.vals.split) != 2) {
                stop('must be specified as -gname=<gname1>:<gname2>')
            } else {
                gname1 <- sep.vals.split[1]
                gname2 <- sep.vals.split[2]
            }
        }
        else { stop('No value provided for parameter -gname=')}
    }
    else if (grepl('^-nrowname=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            nrowname <- as.numeric(arg.split[2])
        }
        else { stop('No value provided for parameter -nrowname=')}
    }
    else if (grepl('^-ncolskip=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            ncolskip <- as.numeric(arg.split[2])
        }
        else { stop('No value provided for parameter -ncolskip=')}
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
        if (! is.na(arg.split[2]) ) { output <- arg.split[2] }
        else { stop('No output file name provided for parameter -o=')}
    }
}

filename
nrowname
ncolskip
p
num1
num2
output

group <- data.frame(group = factor(c(rep(gname1,num1),rep(gname2,num2))))

### read data
cat('\nread in', filename, '\n',file=stdout())
data <- read.table(filename, header=F, row.names=nrowname, sep="\t")
colnames(data) <- unlist(data[1,])   # ヘッダ文字化け対策 header=Tで読み込むと記号が.になる
data <- data[-1,]

first = dim(data)[2] - 5
last = dim(data)[2]
annotation <- data[,first:last]
data <- data[,-first:-last]

if (ncolskip==1) {
    data[,-1] <- lapply(data[,-1], function(x) as.numeric(as.character(x)))
    annotation <- subset(annotation,rowSums(data[,-1])!=0)
    data <- subset(data,rowSums(data[,-1])!=0)
    genename <- data[,1]
    data <- data[,-1]
} else if (ncolskip==2) {
    data[,-1:-2] <- lapply(data[,-1:-2], function(x) as.numeric(as.character(x)))
    annotation <- subset(annotation,rowSums(data[,-1:-2])!=0)
    data <- subset(data,rowSums(data[,-1:-2])!=0)
    genename <- data[,1:2]
    colnames(genename) <- c('genename','id')
    data <- data[,-1:-2]
} else {
    data <- subset(data,rowSums(data)!=0)
}

counts <- as.matrix(data)
counts <- floor(counts) # DESeq2は整数しか受け付けない

suppressPackageStartupMessages({
    library(DESeq2)
    library(ggplot2)
})

dds <- DESeqDataSetFromMatrix(countData = counts, colData = group, design = ~ group)
dds <- DESeq(dds)

dds@colData
counts_norm <- t(t(counts) / dds$sizeFactor)

res <- results(dds, alpha = p)
head(res)
summary(res)

# shrinkage (apeglm)
resLFC <- lfcShrink(dds, coef=2, type="apeglm")

pdf(paste(output, ".DESeq2.MAplot.pdf", sep=""), height=6, width=12)
par(mfrow=c(1,2))
plotMA(res, main="MAplot", ylim=c(-2,2), alpha = p)
plotMA(resLFC, main="MAplot shrunken apeglm", ylim=c(-2,2), alpha = p)
dev.off()

pdf(paste(output, ".DESeq2.Dispersionplot.pdf", sep=""), height=7, width=7)
plotDispEsts(dds)
dev.off()

## ----log+1よりも頑健な補正法
vsd <- vst(dds, blind=FALSE)
#rld <- rlog(dds, blind=FALSE)
#vsd <- varianceStabilizingTransformation(dds)
head(assay(vsd), 3)

#rlogMat <- assay(rld)
vsdMat <- assay(vsd)

cnts <- cbind(rownames(counts_norm), genename, counts_norm, vsdMat, res, annotation)
colnames(cnts)[1] <- "Gene id"
#cnts_vsd <- cbind(rownames(vsdMat), vsdMat, res)


# https://staffblog.amelieff.jp/entry/biomart
#library(biomaRt)
#db <- useMart("ensembl")
#hd <- useDataset("hsapiens_gene_ensembl", mart = db)

#geneanno <- getBM(attributes = c("ensembl_gene_id", "hgnc_symbol", "description"),
#         filters = "ensembl_gene_id", values = rownames(counts_norm),
#         mart = hd, useCache = FALSE)


# FDRでランキング
                                        #resAndvsd <- transform(exp=assay(vsd), res)
                                        #resOrdered <- resAndvsd[order(res$padj),]
resOrdered <- cnts[order(cnts$pvalue),]
resSig <- subset(resOrdered, padj < p)

write.table(resOrdered, file=paste(output, ".DESeq2.all.tsv", sep=""), quote=F, sep="\t",row.names = F, col.names = T)
write.table(resSig,     file=paste(output, ".DESeq2.DEGs.tsv", sep=""), quote=F, sep="\t",row.names = F, col.names = T)
write.table(resSig[resSig$log2FoldChange>0,], file=paste(output, ".DESeq2.upDEGs.tsv", sep=""), quote=F, sep="\t",row.names = F, col.names = T)
write.table(resSig[resSig$log2FoldChange<0,], file=paste(output, ".DESeq2.downDEGs.tsv", sep=""), quote=F, sep="\t",row.names = F, col.names = T)

# Volcano plot
cat('\nmake Volcano plot\n',file=stdout())
library(ggplot2)
library(ggrepel)
volcanoData <- data.frame(Gene=resOrdered$genename, logFC=resOrdered$log2FoldChange,
                          FDR=-log10(resOrdered$padj), significant=resOrdered$padj < p)
volc = ggplot(volcanoData, aes(logFC, FDR)) +
    geom_point(aes(col=significant)) +
    scale_color_manual(values=c("black", "red")) +
    ggtitle(paste("Volcano plot (", gname1, ", ", gname2, ")", sep=""))
volc = volc + geom_text_repel(data=head(volcanoData[order(volcanoData$FDR, decreasing=T),], 20), aes(label=Gene))
ggsave(paste(output, ".DESeq2.Volcano.pdf", sep=""), plot=volc, device="pdf")


pdf(paste(output, ".DESeq2.topDEGs.pdf", sep=""), height=14, width=14)
par(mfrow=c(3,3))
topDEGsid <- order(res$padj, decreasing=F)[1:9]
for(i in topDEGsid) {
    plotCounts(dds, gene=i, intgroup="group")
#    d <- plotCounts(dds, gene=which.min(res$padj), intgroup="group", returnData=T)
#    ggplot(d, aes(x=group, y=count)) + geom_point(position=position_jitter(w=0.1,h=0)) + scale_y_log10(breaks=c(25,100,400))
}
dev.off()

## SD against mean
#library("vsn")
#pdf(paste(output, ".MeanVariance.pdf", sep=""), height=7, width=9)
#par(mfrow=c(1,2))
#meanSdPlot(log2(counts(dds,normalized=T) + 1))
#meanSdPlot(rlogMat)
#meanSdPlot(vsdMat)
#meanSdPlot(vsdfastMat)
#dev.off()

# heatmap of top20 highly-expressed genes
library(pheatmap)
select <- order(rowMeans(counts(dds,normalized=TRUE)), decreasing=TRUE)[1:20]

nt <- normTransform(dds) # log2(x+1)
df <- as.data.frame(colData(dds)[,c("group","group")])
pdf(paste(output, ".DESeq2.HighlyExpressedGenes.pdf", sep=""), height=7, width=7)
#par(mfrow=c(1,2))
#pheatmap(assay(nt)[select,], cluster_rows=F, show_rownames=T, cluster_cols=F, annotation_col=df)
pheatmap(vsdMat[select,], cluster_rows=F, show_rownames=T, cluster_cols=F, annotation_col=df)
dev.off()

# sample clustering
library("RColorBrewer")
sampleDists <- dist(t(vsdMat))
sampleDistMatrix <- as.matrix(sampleDists)
#rownames(sampleDistMatrix) <- paste(rld$condition, rld$type, sep="-")
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
pdf(paste(output, ".DESeq2.sampleClustering.pdf", sep=""), height=7, width=8)
pheatmap(sampleDistMatrix, clustering_distance_rows=sampleDists, clustering_distance_cols=sampleDists, col=colors)
dev.off()

# PCA plot
pdf(paste(output, ".DESeq2.samplePCA.pdf", sep=""), height=7, width=7)
plotPCA(vsd, intgroup=c("group"))
dev.off()

q("no")


# multifactor designs
#designの中の特定のtypeをcontrastにする（single-factor Wald test）
res.A.B <- results(dds, contrast=c("condition","A","B"))
res.A.C <- results(dds, contrast=c("condition","A","C"))
res.B.C <- results(dds, contrast=c("condition","B","C"))

head()
resOrdered <- res.A.B[order(res.A.B$padj),]

# one-way ANOVA (p-value indicates difference at least in one condition)
ddsLRT <- DESeq(dds, test="LRT", reduced= ~ 1)
resLRT <- results(ddsLRT)


# 多群間二因子比較
group <- data.frame(
  condition = factor(c(rep("K",6),rep("W",6))),
  day = factor(c(rep(c(0,2,7),4)))
)
model.matrix(~ group$con + group$day)

dds <- nbinomLRT(dds, full = ~ condition + day, reduced = ~ day)
res <- results(dds)
res
head(res[order(res$pvalue), ])

dds <- nbinomLRT(dds, full = ~ condition + day, reduced = ~ condition)
res <- results(dds)
res
head(res[order(res$pvalue), ])

dds <- estimateSizeFactors(dds)
dds <- estimateDispersions(dds)
res <- results(dds)
