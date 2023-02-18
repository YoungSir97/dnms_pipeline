library(ggplot2)
library("ggpubr")

chrsize <- read.csv("./chr_size.csv",header = T)
#chrsize <- read.csv("./chr_size_oldgenome.csv",header = T)
head(chrsize)

p1 <- ggscatter(chrsize, x = "size", y = "N_dnm", add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "spearman",
          add.params = list(color = "blue", fill = "lightgray"))+
  xlab("Chromosome size")+
  ylab("Number of de novo mutation")+
  scale_x_continuous(labels = as.character(c("0", "50Mb", "100Mb", "150Mb")))+
  theme(
    axis.title.x=element_text(size=15),
    axis.title.y=element_text(size=15))  #设置标题居中
p1
ggsave("./相关性_chrSize_dnms.pdf",plot = p1,width = 5,height = 4)
#ggsave("./相关性_chrSize_dnms_oldgenome.pdf",plot = p1,width = 5,height = 4)


