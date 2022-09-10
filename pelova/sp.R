# Load libraries ----
library(pdfetch)
library(lubridate)
library(dplyr)
library(imputeTS)
# Download historic info S&P 500 ----
rm(list=ls())
rm(list=ls())
aux=pdfetch_YAHOO("^GSPC",from =as.Date("2002-06-30"),to=as.Date("2022-06-30"))
dd=as.data.frame(aux)
adj.cp=data.frame(date=rownames(dd),adj=dd$`^GSPC.adjclose`)
adj.cp$date=ymd(adj.cp$date)#lubridate
date=seq(from=min(adj.cp$date),to=max(adj.cp$date),by="days")
ddn=data.frame(date=date,weekday=wday(date,week_start = 1))
ddn=ddn[ddn$weekday<6,]
ddn=left_join(ddn, adj.cp,by="date")# dplyr
rm(adj.cp,dd,aux,date)

# Impute missing entries ----
colSums(is.na(ddn))
# Assuming that EMH holds true, we apply LOCF technique to impute missing observations
ddn$adj.im=na_locf(ddn$adj,option="locf")
# Look at the data first ----
# 1. Visualize data ----
# https://www.statmethods.net/advgraphs/parameters.html
# windows()
setwd("C:/Users/bpelova/Desktop/uni/courses/quant_fin/topic3")
windows()
  plot(ddn$date,ddn$adj.im, type="l", col="blue",lwd=2,xlab="Date",ylab="Adjusted closing price",main="S&P 500",xaxt="n")
  x=seq(from=min(ddn$date),to=max(ddn$date), by="years")
  axis(side=1,at=x,labels=year(x),las=2)
  abline(v=x,h=seq(from=1000,by=500,to=4000),col="gray",lty=3)
