library(ggplot2)
library(ggpubr)
library(tidyverse)
library(getopt)

arg <- matrix(c("indir", "i","1","character","input directory",
                "prefix","p","1","character","prefix of file name",
                "sample","s","1","character","samples group",
                "height","l","1","integer","image height,default=20",
                "width","w","1","integer","image width,default=15",
                "help","h","0","logical", "Usage: Rscript plot_SNPs_PCA.R -i <dir> -p <file prefix> -s <sample list>"),byrow=T,ncol=5)
opt = getopt(arg)

if(!is.null(opt$help) || is.null(opt$indir) || is.null(opt$prefix) || is.null(opt$sample)){
    cat(paste(getopt(arg, usage = T), "\n"))
    q()
}
if (is.null(opt$width)){
    opt$width <- 10
}
if (is.null(opt$height)){
    opt$height <- 7
}

setwd(opt$indir)
filename <- opt$prefix
pca <- read.table(paste0(filename,".eigenvec"), header = F)
pca <- pca[,1:5]
eigval <- read.table(paste0(filename,".eigenval"), header = F)
pcs <- paste0("PC", 1:nrow(eigval))
eigval[nrow(eigval),1] <- 0
percentage <- eigval$V1/sum(eigval$V1)*100
eigval_df <- as.data.frame(cbind(pcs, eigval[,1], percentage), stringsAsFactors = F)
names(eigval_df) <- c("PCs", "variance", "proportion")
eigval_df$variance <- as.numeric(eigval_df$variance)
eigval_df$proportion <- as.numeric(eigval_df$proportion)
pc1_proportion <- paste0(round(eigval_df[1,3],2),"%")
pc2_proportion <- paste0(round(eigval_df[2,3],2),"%")

sample <- read.table(opt$sample, header = F)

data <- left_join(pca,sample,by="V1")
data <- data[,-2] 
colnames(data) <- c("Sample","PC1","PC2","PC3","Type")
#data$Type <- factor(data$Type, levels = c("Group1","Group2","Group3"))
p <- ggplot(data,aes(PC1,PC2))+
geom_point(aes(color=Type), size=5)+
geom_text(aes(x=PC1,y=PC2,label=Sample),size=1,alpha=0.6)+
#stat_ellipse(aes(color=Type),level = 0.95, show.legend = FALSE, size=1)+
#scale_color_manual(values = c("#2a6117","#e93122","#0042f4"))+
labs(x=paste0("PC1(",pc1_proportion,")"),y=paste0("PC2(",pc2_proportion,")"))+
theme(panel.grid = element_blank(),
      panel.background = element_blank(),
      panel.border = element_rect(fill = NA, colour = "black"),
      legend.title = element_blank(),
      legend.key = element_blank(),
      axis.text = element_text(colour = "black", size=12),
      axis.title = element_text(color="black",size = 15),
      legend.text = element_text(colour = "black", size=12),
      #legend.position = c(0.15,0.15)
      )
#p
ggsave(paste0(filename,".pdf"),plot=p,width=opt$width,height=opt$height)

