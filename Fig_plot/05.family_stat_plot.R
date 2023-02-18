library(ggplot2)
library(ggthemes)

dt <- read.csv("./DNMs_information_list2.csv",header = T)
head(dt)
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
ggsave("05.offdpring_dnm_numbers.pdf",plot = pp,width = 10,height = 6)

### old genome
dt2 <- read.csv("./DNMs_information_list_oldgenome.csv",header = T)
## Statistics of the number of DNMs on offspring
dt2$offspring <- factor(dt2$offspring, levels = c("F07055","F07056","F08856","F08858",
                                                "F07063","F07064","F07065","F07066",
                                                "F07068","F07069","F07070","F08859",
                                                "F07062","F07059","F07060","F08857"))
pp2 <- ggplot(dt,mapping = aes(x=offspring,fill=Family)) + geom_bar(stat = "count") +
  #scale_fill_manual(values=c("#ddb0ff","#ffa0df","#66d8dc","#66ccff")) +
  labs(title = "Statistics of the number of DNMs on offspring")+
  geom_text(stat='count',aes(label=..count..), vjust=1.6, color="white", size=3.5)+
  theme_bw()
pp2
ggsave("05.offdpring_dnm_numbers_oldgenome.pdf",plot = pp2,width = 10,height = 6)
