library(reshape2)
library(plyr)
library(ggplot2) 
source("R/graph/utils.R")

occ_dayCollected <- function(sourceFile, targetDir) {
  print(paste("Processing day collected graphs for: ", sourceFile))
  dir.create(targetDir, showWarnings=F)  
  
  DF <- read.table(sourceFile, header=T, sep=",")
  DF <- DF[DF$snapshot %in% temporalFacetSnapshots,]
  
  p1 <- ggplot(arrange(DF,day,occurrenceCount), aes(x=day,y=occurrenceCount)) + 
    geom_area(fill="#ff7f00", alpha='0.7') +
    facet_grid(snapshot~.) +
    ylab("Number of occurrences (in millions)") +
    xlab("Day of year") +
    scale_y_continuous(label = mill_formatter) +
    ggtitle("Number of occurrences per day of year") 
  
  #ggsave(filename=paste(targetDir, "occ_dayCollected.png", sep="/"), plot=p1, width=8, height=6 )
  savePng(p1, paste(targetDir, "occ_dayCollected.png", sep="/"))
}
