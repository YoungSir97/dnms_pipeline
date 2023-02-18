library(getopt)

arg <- matrix(c("indir", "i","1","character","input directory of PD file,",
                "samples","s","1","integer","the numbers of sample",
                "output","o","1","character","prefix of output file",
                "height","l","1","integer","image height,default=20",
                "width","w","1","integer","image width,default=15",
                "help","h","0","logical", "Usage: Rscript 12_depthPlot.R -i <dir> -s <int> -o <prefix>"),byrow=T,ncol=5)
opt = getopt(arg)

if(!is.null(opt$help) || is.null(opt$indir) || is.null(opt$output) || is.null(opt$samples)){
    cat(paste(getopt(arg, usage = T), "\n"))
    q()
}
if (is.null(opt$width)){
        opt$width <- 24
}
if (is.null(opt$height)){
        opt$height <- 32
}

# define the file names list (21 samples here)
n <- opt$samples*2+1
nameList <- c()
for (i in 3:n) { # 43 - odd number for 21 samples 
      if (i %% 2 ==1) nameList <- append(nameList, paste0(opt$indir,"/",i, ".DP"))
}

qlist <- matrix(nrow = opt$samples, ncol = 4) # define number of samples (10 samples here)
qlist <- data.frame(qlist, row.names=nameList)
colnames(qlist)<-c('5%', '50%', '95%', '99%')

pdf(paste0(opt$output,".DP.pdf"), height=opt$height, width=opt$width)
par(mar=c(5, 3, 3, 2), cex=1.5, mfrow=c(8,4)) # define number of plots for your sample
for (i in 1:opt$samples) {
    DP <- read.table(nameList[i], header = T)
    qlist[i,] <- quantile(DP[,1], c(.05, .5, .95, .99), na.rm=T)
    d <- density(DP[,1], from=0, to=100, bw=1, na.rm =T)
    plot(d, xlim = c(0,100), main=colnames(DP), col="blue", xlab = dim(DP)[1], lwd=2)
    abline(v=qlist[i,c(1,4)], col='red', lwd=3)
}
dev.off()

write.table(qlist, paste0(opt$output,".DP.percentiles.txt"))

