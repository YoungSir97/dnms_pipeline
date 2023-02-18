# define the file names list (21 samples here)
nameList <- c()
for (i in 3:43) { # 43 - odd number for 21 samples 
      if (i %% 2 ==1) nameList <- append(nameList, paste0("/public/home/wanglab2021/1.Project/00.RawData_20210817/process/vcf/",i, ".DP"))
}

qlist <- matrix(nrow = 21, ncol = 3) # define number of samples (10 samples here)
qlist <- data.frame(qlist, row.names=nameList)
colnames(qlist)<-c('5%', '10%', '99%')

pdf("/public/home/wanglab2021/1.Project/00.RawData_20210817/process/report/6_depthPlot.DP.pdf", height=32, width=24)
par(mar=c(5, 3, 3, 2), cex=1.5, mfrow=c(8,4)) # define number of plots for your sample
for (i in 1:21) {
    DP <- read.table(nameList[i], header = T)
    qlist[i,] <- quantile(DP[,1], c(.05, .1, .99), na.rm=T)
    d <- density(DP[,1], from=0, to=100, bw=1, na.rm =T)
    plot(d, xlim = c(0,100), main=colnames(DP), col="blue", xlab = dim(DP)[1], lwd=2)
    abline(v=qlist[i,c(1,3)], col='red', lwd=3)
}
dev.off()

write.table(qlist, "/public/home/wanglab2021/1.Project/00.RawData_20210817/process/report/6_depthPlot.DP.percentiles.txt")

