library(ggplot2)
library(lme4)
library(data.table)
library(ggpmisc)

dt <- data.table(read.csv("./parent_age_effect.csv",header = T))
head(dt)
#str(dt)

### 线性回归
m1 <- lm(Rate ~ Father_age,data = dt)
summary(m1)
### GLM
m2 <- glmer(fromFather ~ lay_group + (1|Mutation),family = 'poisson', data = dt)
summary(m2)

m3 <- lmer(Mutation ~ Father_age + Mother_age + (1|Family), data = dt)
summary(m3)

# 利用模型求出给定x，y的拟合值，以及拟合值的置信区间
p1 <- ggplot(dt,aes(x=Father_age,y=Rate)) + geom_point() +
  geom_smooth(method="lm")+ 
  stat_poly_eq(aes(label = paste(..eq.label.., ..adj.rr.label.., sep = '~~~~')), 
               formula = y ~ x, parse = T) + #添加回归方程和调整R方
  ylab("De novo muatation rate") +
  xlab("Father age")+
  theme_classic()
p1
ggsave("04.father_age_effect.pdf",plot = p1, width = 5,height = 4)

p2 <- ggplot(dt,aes(x=Mother_age,y=Rate)) + geom_point() +
  geom_smooth(method="lm")+ 
  stat_poly_eq(aes(label = paste(..eq.label.., ..adj.rr.label.., sep = '~~~~')), 
               formula = y ~ x, parse = T) + #添加回归方程和调整R方
  ylab("De novo muatation rate") +
  xlab("Mother age")+
  theme_classic()
p2
ggsave("04.mother_age_effect.pdf",plot = p2, width = 5,height = 4)

