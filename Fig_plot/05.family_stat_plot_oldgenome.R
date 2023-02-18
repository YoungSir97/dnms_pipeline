library(ggplot2)
library(ggthemes)
library(data.table)

dt <- read.csv("./DNMs_check_list.csv",header = T)
dt <- data.table(dt)
## Statistics of the number of DNMs on offspring
dt$offspring <- factor(dt$offspring, levels = c("F07055","F07056","F08856","F08858",
                                                "F07063","F07064","F07065","F07066",
                                                "F07068","F07069","F07070","F08859",
                                                "F07062","F07059","F07060","F08857"))
pp <- ggplot(dt,mapping = aes(x=offspring,fill=Family)) + geom_bar(stat = "count") +
  #scale_fill_manual(values=c("#ddb0ff","#ffa0df","#66d8dc","#66ccff")) +
  labs(title = "Statistics of the number of DNMs on offspring")+
  geom_text(stat='count',aes(label=..count..), vjust=1.6, color="white", size=3.5)+
  theme_bw()
pp
ggsave("offdpring_DNMs1_oldgenome.pdf",plot = pp,width = 10,height = 6)

## Statistics of the number of DNMs on chromosome
lv <- c("chr2","chr1","chr3","chrZ","chr1A","chr4",
       "chr5","chr7","chr6","chr8","chr9","chr11","chrW","chr10","chr12","chr4A",
       "chr13","chr14","chr20","chr15","chr17","chr18","chr19","chr21","chr24",
       "chr26","chr23","chr28","chr27","chr22","chr25","chr29","chr35","chr30",
       "chr32","chr31","chr37","chr34","chr33","chr16","chr36")
dt$chr <- factor(dt$chr, levels = lv)
ggplot(dt) + geom_bar(mapping = aes(x=chr), stat = "count") +
  xlab("chromosome")+
  labs(title = "Statistics of the number of DNMs on chromosome")+
  theme_bw()

##
chrsize <- read.csv("./chr_size.csv",header = T)
chrsize$chr <- factor(chrsize$chr, levels = lv)

p1 <- ggplot(chrsize, aes(chr, Size)) +
  geom_col(fill = 'grey', color = 'black', width = 0.6) +
  theme(panel.grid = element_blank(), panel.background = element_rect(fill = 'transparent')) +
  theme(axis.line.x = element_line(colour = 'black'), 
        axis.line.y = element_line(colour = 'transparent'),
        axis.ticks.y = element_line(colour = 'transparent')) +
  geom_hline(yintercept = 0) +
  coord_flip() +
  labs(x = '', y = 'chromosome size') +
  scale_y_continuous(expand = c(0, 0), breaks = c(0, 50, 100,150 ),
                     labels = as.character(c("0", "50Mb", "100Mb", "150Mb")))+
  scale_x_discrete(position = 'top')
p1

chrnum <- dt[, -.N, by=chr]
p2 <- ggplot(chrnum, aes(x=chr,y=V1)) +
  geom_col(fill = 'red2', color = 'black', width = 0.6) +
  theme(panel.grid = element_blank(), panel.background = element_rect(fill = 'transparent')) +
  theme(axis.line.x = element_line(colour = 'black'), 
        axis.line.y = element_line(colour = 'transparent'), 
        axis.ticks.y = element_line(colour = 'transparent')) +
  coord_flip() +
  labs(x = '', y = 'numbers of DNM on chromosome') +
  geom_hline(yintercept = 0) +
  scale_y_continuous(expand = c(0, 0), breaks = c(-15,-10,-5,0), 
                     labels = as.character(c( "15","10", "5", "0"))) + #这儿更改间距设置
  scale_x_discrete(position = 'top')
p2

library(cowplot)
plot_grid(p2, p1, nrow = 2, ncol = 2, rel_heights = c(9, 1))


## The source of de novo mutations (paternal/maternal)

stat <- dt[, .N, by = .(family, source)]
head(stat)
stat$source <- factor(stat$source, levels = c("F07051","F07053","F07052","F07054","unknown"),
                      labels = c("F07051♀","F07053♀","F07052♂","F07054♂","unknown"))
ggplot(stat, aes(x=family,y=N,fill=source)) +
  geom_bar(stat="identity", position=position_dodge(), color = "black", size = 0.2,width = 0.8) +
  scale_fill_manual(values=c("#f8766d","#f8766d","#00b0f6","#00b0f6","grey")) +
  labs(title = "The source of de novo mutations")+
  xlab("DNMs source") +
  ylab("Number of DNMs")+
  theme_few()+
  theme(axis.title.x=element_text(size=15),
    axis.title.y=element_text(size=15),
    legend.title = element_blank(),
    legend.position = c(0.1, 0.9),
    plot.title = element_text(hjust = 0.5,face = "bold",size=17))  #设置标题居中



stat[,value:=N/sum(N),by=family]
ggplot(stat, aes(x="", y=value, group=source, fill=source)) + 
  geom_bar(stat="identity") +
  coord_polar("y", start=0) +
  facet_grid(.~family) +
  geom_text(aes(label=N), position = position_stack(vjust = 0.5)) +
  scale_fill_manual(values=c("#e76bf3","#f8766d","#00bf7d","#00b0f6","grey")) +
  labs(title = "The source of de novo mutations (paternal/maternal)")+
  theme_void()

                            