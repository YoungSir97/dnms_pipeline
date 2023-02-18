library(ggplot2)
library(ggthemes)
library(data.table)

dt <- read.csv("./DNMs_information_list2.csv",header = T)
dt <- data.table(dt)
head(dt)

## The source of de novo mutations (paternal/maternal)
stat <- dt[, .N, by = .(Family, Source)]
head(stat)
#write.csv(stat,"./parent_source_stat.csv")

p1 <- ggplot(stat, aes(x=Family,y=N,fill=Source)) +
  geom_bar(stat="identity", position=position_dodge(), color = "black",width = 0.6) +
  scale_fill_manual(values=c("#f8766d","#00b0f6","grey")) +
  labs(title = "The source of de novo mutations")+
  xlab("Pedigree") +
  ylab("Number of de novo mutation")+
  theme_few()+
  theme(
    axis.title.x=element_text(size=15),
    axis.title.y=element_text(size=15),
    legend.title = element_blank(),
    legend.position = c(0.1, 0.85),
    plot.title = element_text(hjust = 0.5,face = "bold",size=17))  #设置标题居中
p1
ggsave("./父母来源1.pdf",plot = p1,width = 7,height = 5)

## boxplot
stat2 <- stat[Source!='unknown']
p2 <- ggplot(stat2,aes(x=Source, y=N)) + 
  geom_boxplot(aes(color=Source)) +
  geom_point(aes(color=Source), position=position_jitterdodge()) + 
  geom_signif(comparisons = list(c("maternal","paternal")),
              map_signif_level = function(p) sprintf("p = %.2g", p),
              step_increase = 0.1, test = t.test) +
  scale_color_manual(values=c("#f8766d","#00b0f6")) +
  ylab("Number of de novo mutation")+
  labs(title = "The source of de novo mutations")+
  theme_few()+
  theme(
    axis.title.x=element_text(size=16),
    axis.title.y=element_text(size=16),
    legend.title = element_blank(),
    legend.position = c(0.15, 0.85),
    plot.title = element_text(hjust = 0.5,face = "bold",size=17))  #设置标题居中
p2
ggsave("./父母来源2.pdf",plot = p2,width = 5,height = 5)

### 二项分布
dt[, .N, by = .(Source)]
binom.test(74,99) # test paternal bias

### fisher test
dat <- data.frame(
  paternal = c(74,50),
  maternal = c(25,50),
  row.names = c("observed", "expected"),
  stringsAsFactors = FALSE)
dat
fisher.test(dat)





                            