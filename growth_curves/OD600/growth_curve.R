
setwd("/Users/kubotan/Documents/github/pf_cheater_phage")

file <- "./growth_curves/OD600/Plate_reader_2024-06-30.csv"
p <- read.csv(file,header=T,skip = 2)

p <- head(p,-5) #remove last few rows
p <- p[,-2] #remove temperature column

p[97,which(colnames(p)%in%"Time")]  <- c("24:00:00") #run for newer program

k <- "./growth_curves/OD600/Plate_key_2024-06-29.csv"
key <- read.csv(k,header=F) #key to denote what samples are in each well

library(ggplot2)
library(reshape2)
library(RColorBrewer)

for (i in 2:ncol(p)) {
  well <- colnames(p)[i]
  num <- which(key[,1]%in%well)
  colnames(p)[i] <- as.character(key[num,2])
}

blank <- p[,which(colnames(p)%in%"blank")]
indx <- sapply(blank, is.character)
blank[indx] <- lapply(blank[indx], function(x) as.numeric(x))
blank_mean <- data.frame(Time=p[,1],Means=rowMeans(blank,na.rm=TRUE))
pdata <- p[,-which(colnames(p)%in%"blank")]
pdata$blank_mean <- blank_mean[,2] #name new column blank_mean with average of all blanks

#growth curve stats
library(growthcurver)
gc_p <- pdata
# Function to convert all columns to numeric
convert_to_numeric <- function(x) {
  as.numeric(as.character(x))
}
gc_p[,-1] <- as.data.frame(lapply(gc_p[,-1], convert_to_numeric))

names(gc_p)[names(gc_p) == 'blank_mean'] <- 'blank'

gc_p$Time <- as.factor(gc_p$Time)
gc_p$Time <- unlist(lapply(lapply(strsplit(as.character(gc_p$Time), ":"), as.numeric), function(x) x[1]+x[2]/60))
colnames(gc_p)[1] <- "time"
colnames(gc_p)[2] <- "NA.0"

gc_out <- SummarizeGrowthByPlate(gc_p,bg_correct = "blank")
gc_out$sample <- gsub("\\..*","",gc_out$sample)
gc_out <- head(gc_out, -1) #remove last row (i.e. blank)
gc_out2 <- gc_out[which(gc_out$sample != "NA"),]

output_file_name <- "./growth_curves/OD600/growth_curve_calc.csv" #your output file location
write.csv(gc_out2, file = output_file_name, quote = FALSE, row.names = FALSE)

