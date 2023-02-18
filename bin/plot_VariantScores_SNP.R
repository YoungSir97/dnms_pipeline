library('gridExtra')
library('ggplot2')
library(getopt)

arg <- matrix(c("snp", "s","1","character","input SNPs table file",
                "output","o","1","character","output",
                "height","l","1","integer","image height,default=20",
                "width","w","1","integer","image width,default=15",
                "help","h","0","logical", "Usage: Rscript 12_plot_VariantScores_SNP.R -s <snp.table> [-o output]"),byrow=T,ncol=5)
opt = getopt(arg)

if(!is.null(opt$help) || is.null(opt$snp)){
    cat(paste(getopt(arg, usage = T), "\n"))
    q()
}
if (is.null(opt$output)){
    opt$output <- "plot_VariantScores_SNP.pdf"
}
if (is.null(opt$width)){
    opt$width <- 15
}
if (is.null(opt$height)){
    opt$height <- 20
}

# default cutoffs
QD_cutoff = 2
FS_cutoff = 60
MQ_cutoff = 40
MQRankSum_cutoff = -12.5
SOR_cutoff = 3
ReadPosRankSum_cutoff = -8

# read table
VCF <- read.csv(opt$snp, header = T, na.strings=c("","NA"), sep = "\t")
#dim(VCF)
VCF$Variant <- factor(rep("SNPs", dim(VCF)[1]))
snps <- '#00bfff'

# plot density
DP <- ggplot(VCF, aes(x=DP, fill=Variant)) + geom_density(alpha=0.3)
    #geom_vline(xintercept=DP_cutoff, colour=snps, linetype="dashed") + xlim(0,2000) +

QD <- ggplot(VCF, aes(x=QD, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=QD_cutoff, colour=snps)

FS <- ggplot(VCF, aes(x=FS, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=FS_cutoff,colour=snps) + xlim(0,200)

MQ <- ggplot(VCF, aes(x=MQ, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=MQ_cutoff,colour=snps)

MQRankSum <- ggplot(VCF, aes(x=MQRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=MQRankSum_cutoff,colour=snps) + xlim(-15,15)

SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=SOR_cutoff,colour=snps) + xlim(0,10)

ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=ReadPosRankSum_cutoff,colour=snps) + xlim(-10, 10)

# output
pdf(opt$output,height=opt$height, width=opt$width)
theme_set(theme_gray(base_size = 18))
grid.arrange(QD, DP, FS, MQ, MQRankSum, SOR, ReadPosRankSum, nrow=4)
dev.off()

