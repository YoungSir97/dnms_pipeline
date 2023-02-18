library(ggplot2)
library(ggthemes)

dt <- read.csv("./DNMs_information_list2.csv",header = T)
head(dt)

p1 <- ggplot(dt, aes(x=type2,fill=CpGsite,alpha=CpGsite)) +
  geom_bar(stat="count",position="stack",color="black",width = 0.6)+ 
  scale_fill_manual(values=c("#6b6b6b","#6b6b6b")) +
  scale_alpha_manual(values=c(0.3,1))+
  ggtitle("de novo mutation spectrum")+
  xlab("Type of de novo mutation")+
  ylab("Number of de novo mutation")+
  theme_few()+
  theme(
    axis.title.x=element_text(size=15),
    axis.title.y=element_text(size=15),
    legend.title = element_blank(),
    legend.position = c(0.13, 0.9),
    plot.title = element_text(hjust = 0.5,face = "bold",size=17))  #设置标题居中
p1
ggsave("./突变谱1.pdf",plot = p1,width = 6,height = 5)


p2 <- ggplot(dt, aes(x=type2,fill=Source)) +
  geom_bar(stat="count",position=position_dodge(),color="black")+
  scale_fill_manual(values=c("#f8766d","#00b0f6","grey")) +
  ggtitle("de novo mutation spectrum")+
  xlab("Type of de novo mutation")+
  ylab("Number of de novo mutation")+
  theme_few()+
  theme(plot.title = element_text(hjust = 0.5,face = "bold"),
        legend.title = element_blank(),
        legend.position = c(0.1, 0.85))
p2
ggsave("./突变谱2.pdf",plot = p2,width = 7,height = 5)


## 按父母来源分类
p3 <- ggplot(dt,aes(x=Source,fill=Source,alpha = CpGsite))+
  geom_bar(stat="count",position="stack",color="black") +
  ggtitle("de novo mutation spectrum")+
  facet_wrap(~type2,nrow=1,ncol=6)+
  scale_fill_manual(values=c("#f8766d","#00b0f6","grey")) +
  scale_alpha_manual(values=c(0.3,1))+
  xlab("Type of de novo mutations")+
  ylab("Number of de novo mutation")+
  theme_classic() +
  theme(
    axis.text.x=element_blank(),
    axis.ticks.x=element_blank(),
    axis.title.x=element_text(size=15),
    axis.title.y=element_text(size=15),
    strip.text.x=element_text(face="italic",size=12),
    legend.title = element_blank(),
    legend.position = c(0.1, 0.8),
    plot.title = element_text(hjust = 0.5,face = "bold",size=17))  #设置标题居中
p3
ggsave("./突变谱3.pdf",plot = p3,width = 7,height = 5)

