# Import data ----

# https://www.census.gov/retail/mrts/www/benchmark/2019/html/annrev19.html
rm(list=ls())
setwd("C:\\Users\\Boryana Bogdanova\\Desktop\\uni\\MSc_courses\\Fin_Rets\\topic2\\2020")

# Load libraries
library(readxl)
library(dplyr)
library(lubridate)

# Import data on Retail and food services sales, total
dd=list()
for (i in 1:27){
  dd[[i]]=read_excel("benchsales19.xls",sheet=i+1,range="C5:N7")
}
# Convert the data into a data frame
ddn=list()
for (i in 1:27){
  ddn[[i]]=data.frame(DATE=colnames(dd[[i]],), VALUE=as.numeric(dd[[i]][2,]))
}
rm(dd)
dd=ddn[[27]]
for (i in 1:26){
  dd=bind_rows(dd,ddn[[27-i]])
}
rm(ddn,i)
# Check classes and fix inconsistencies
sapply(dd,class)
dd$DATE[1:5]
dd$DATE=gsub(". ","/",dd$DATE)
dd$DATE=paste("1",dd$DATE,sep="/")
dd$DATE=dmy(dd$DATE)

# Get month
dd$MONTH=month(dd$DATE)
windows()
plot(dd$DATE,dd$VALUE,type="l",col="blue",lwd=2, panel.first=grid(),xlab="",ylab="")

# Get values after 2010 
dd=dd[dd$DATE>="2010-01-01",]

# Calculate seasonal factor weigths----
# Derive ybar
ybar=rep(NA,nrow(dd))
for (i in 1:nrow(dd)){
  ybar[i]=ifelse(i<5, mean(dd$VALUE[1:(i+6)]),ifelse(i<=nrow(dd)-6,mean(dd$VALUE[(i-5):(i+6)]),mean(dd$VALUE[(i-5):nrow(dd)])))
}
lines(dd$DATE,ybar,col="red",lwd=2)
# Derive Z
z=dd$VALUE/ybar
windows()
plot(dd$DATE,z,type="l",col="blue",lwd=2,xlab="",ylab="",panel.first=grid())

# Derive Zbar
zbar=rep(NA,12)
for (i in 1:12){
  zbar[i]=mean(z[dd$MONTH==i])
}
sum(zbar)
# Derive Zwave
zwave=zbar*12/sum(zbar)
sum(zwave)
zwave
windows()
plot(dd$MONTH[1:12],zwave,type="l",col="blue",lwd=2,xlab="",ylab="",panel.first=grid())
# You might wish to write own function
s_weights=function(y,s,k){
  
  ybar=rep(NA,length(y))
  for (i in 1:length(y)){
    ybar[i]=ifelse(i<(k/2-1), mean(y[1:(i+k/2)]),ifelse(i<=length(y)-k/2,mean(y[(i-(k/2-1)):(i+k/2)]),mean(y[(i-(k/2-1)):length(y)])))
  }
  
    z=y/ybar
    zbar=rep(NA,k)
    for (i in 1:k){
      zbar[i]=mean(z[s==i])
    }
    
    zwave=zbar*k/sum(zbar)
    
    return(zwave)
}
# Seasonally adjust data ----
W=data.frame(MONTH=c(1:12),W=zwave)
dd=left_join(dd,W,by="MONTH")
dd$adj=dd$VALUE/dd$W
windows()
plot(dd$DATE,dd$adj,col="blue",type="l",lwd=2,xlab="",ylab="",panel.first=grid(),xlim=c(as.Date("2010/1/1"),as.Date("2019/12/1")))
# Fit trend model and derive 1 year ahead forecast----
dd$t=c(1:nrow(dd))
eq=lm(adj~t,data=dd)
summary(eq)
f=predict(object=eq,newdata=data.frame(t=c((nrow(dd)+1):(nrow(dd)+12))))
lines(dd$DATE,eq$fitted.values,col="red",lwd=2)
lines(seq(as.Date("2019/1/1"),as.Date("2019/12/1"),"months"),f,lwd=2,col="red")
# Adjust forecast with seasonal weigths
ff=f*W$W
windows()
plot(seq(as.Date("2019/1/1"),as.Date("2019/12/1"),"months"),ff,type="l",lwd=2,col="red",xlab="",ylab="",panel.first=grid(),xlim=c(as.Date("2010/1/1"),as.Date("2019/12/1")),ylim=c(min(dd$VALUE),max(ff)))
lines(dd$DATE,dd$VALUE,col="blue",type="l",lwd=2)

