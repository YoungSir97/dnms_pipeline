library('gridExtra')
library('ggplot2')
library(getopt)

arg <- matrix(c("snp", "s","1","character","input SNPs table file",
                "indel","i","1","character","input INDELs table file",
                "output","o","1","character","output",
                "height","l","1","integer","image height,default=20",
                "width","w","1","integer","image width,default=15",
                "help","h","0","logical", "Usage: Rscript 12_plot_VariantScores.R -s <snp.table> -i <indel.table> [-o output]"),byrow=T,ncol=5)
opt = getopt(arg)

if(!is.null(opt$help) || is.null(opt$snp) || is.null(opt$indel)){
    cat(paste(getopt(arg, usage = T), "\n"))
    q()
}
if (is.null(opt$output)){
    opt$output <- "plot_VariantScores"
}
if (is.null(opt$width)){
    opt$width <- 15
}
if (is.null(opt$height)){
    opt$height <- 20
}

VCFsnps <- read.csv(opt$snp, header = T, na.strings=c("","NA"), sep = "\t") 
VCFindel <- read.csv(opt$indel, header = T, na.strings=c("","NA"), sep = "\t")
#dim(VCFsnps)
#dim(VCFindel)
VCF <- rbind(VCFsnps, VCFindel)
VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps)[1]), rep("Indels", dim(VCFindel)[1])))

snps <- '#A9E2E4'
indels <- '#F4CCCA'

DP <- ggplot(VCF, aes(x=DP, fill=Variant)) + geom_density(alpha=0.3) + 
  geom_vline(xintercept=c(10,6200))

QD <- ggplot(VCF, aes(x=QD, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=2)

FS <- ggplot(VCF, aes(x=FS, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=c(60, 200), colour = c(snps,indels)) + ylim(0,0.1)

MQ <- ggplot(VCF, aes(x=MQ, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=40, size=0.7)

MQRankSum <- ggplot(VCF, aes(x=MQRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-20, size=0.7, colour = snps)

SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=c(4, 10), colour = c(snps,indels))

ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=c(-10,10,-20,20), colour = c(snps,snps,indels,indels)) + xlim(-30, 30)

#pdf("/public/home/wanglab2021/1.Project/00.RawData_20210817/process/report/6_plots_for_VariantsScores.pdf", height=20, width=15)
pdf(opt$output,height=opt$height, width=opt$width)
theme_set(theme_gray(base_size = 18))
grid.arrange(QD, DP, FS, MQ, MQRankSum, SOR, ReadPosRankSum, nrow=4)
dev.off()

