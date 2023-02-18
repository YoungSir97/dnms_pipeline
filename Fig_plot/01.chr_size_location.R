library(ggplot2)
library(ggthemes)
library(data.table)

dt <- read.csv("./DNMs_information_list2.csv",header = T)
dt <- data.table(dt)
head(dt)

## Statistics of the number of DNMs on offspring
dt$offspring <- factor(dt$offspring, levels = c("F07055","F07056","F08856","F08858",
                                                "F07063","F07064","F07065","F07066",
                                                "F07068","F07069","F07070","F08859",
                                                "F07062","F07059","F07060","F08857"))
## Statistics of the number of DNMs on chromosome
lv <- c("chr2","chr1","chr3","chrZ","chr1A","chr4",
       "chr5","chr7","chr6","chr8","chr9","chr11","chrW","chr10","chr12","chr4A",
       "chr13","chr14","chr20","chr15","chr17","chr18","chr19","chr21","chr24",
       "chr26","chr23","chr28","chr27","chr22","chr25","chr29","chr35","chr30",
       "chr32","chr31","chr37","chr34","chr33","chr16","chr36")
chrsize <- read.csv("./chr_size.csv",header = T)
chrsize$chr <- factor(chrsize$chr, levels = lv)
dt$chromosome <- factor(dt$chromosome, levels = lv)


## 总图
p1 <- ggplot(dt,aes(x=chromosome)) + 
  geom_bar(aes(y=chr_size),stat = "identity",width=0.5,color="black",fill="white") +
  geom_point(aes(y=position,color=offspring),size=1,stat="identity",position="dodge") +
  coord_flip() +
  labs(x = '', y = 'chromosome size') +
  theme_classic()+
  theme(plot.title = element_text(hjust = 0.5,face = "bold"),
        legend.position = c(0.9, 0.6),
        legend.key.size = unit(12,"pt")) +
  theme(panel.grid = element_blank(), panel.background = element_rect(fill = 'transparent')) +
  theme(axis.line.x = element_line(colour = 'black'), 
        axis.line.y = element_line(colour = 'transparent'),
        axis.ticks.y = element_line(colour = 'transparent')) +
  geom_hline(yintercept = 0)+
  scale_y_continuous(labels = as.character(c("0", "50Mb", "100Mb", "150Mb")))
p1
#ggsave("dnms_location1.pdf",plot = p1,width = 9,height = 5)

chrnum <- dt[, -.N, by=chromosome]
p2 <- ggplot(chrnum, aes(x=chromosome,y=V1)) +
  geom_col(fill = 'red2', color = 'black', width = 0.5) +
  theme(panel.grid = element_blank(), panel.background = element_rect(fill = 'transparent')) +
  theme(axis.line.x = element_line(colour = 'black'), 
        axis.text.y=element_blank(),
        axis.line.y = element_line(colour = 'transparent'), 
        axis.ticks.y = element_line(colour = 'transparent')) +
  coord_flip() +
  labs(x = '', y = 'numbers of DNM on chromosome') +
  geom_hline(yintercept = 0) +
  scale_y_continuous(expand = c(0, 0), breaks = c(-15,-10,-5,0), 
                     labels = as.character(c( "15","10", "5", "0")))  #这儿更改间距设置
p2

library(cowplot)
p3 <- plot_grid(p2, p1, nrow = 1, ncol = 2, rel_heights = c(9, 1),rel_widths = c(1, 3))
p3
ggsave("./dnms_location.pdf",plot = p3,width = 10,height = 5)
  