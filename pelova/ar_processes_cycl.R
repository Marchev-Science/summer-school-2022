# Simmulate AR(1) and AR(2) processes ----
rm(list=ls())
x1=arima.sim(model=list(ar=c(0.9)),5000)
x2=arima.sim(model=list(ar=c(-0.9)),1000)
x3=arima.sim(model=list(ar=c(1.3,-0.4)),1000)
x4=arima.sim(model=list(ar=c(0.9,-0.4)),5000)
# Visualize time series
windows()
layout(matrix(c(1:4),nrow=2,ncol=2,byrow=FALSE))
plot(x1,type="l",col="blue", main="AR(1)process")
acf(x1,lag.max = 35, col="red", main="phi(1)=0.9")
plot(x2,type="l",col="blue", main="AR(1)process")
acf(x2,lag.max = 35, col="red",main="phi(1)=-0.9")

windows()
layout(matrix(c(1,1,2,3),2,2,byrow=T))
plot(x3,type="l",col="blue",lwd=2, main="",xlab="",ylab="")
acf(x3,col="red",lag.max=50,main="ACF")
pacf(x3,col="red",lag.max=50,main="PACF")

# Find roots of the charactristic equation ----
library(signal)
roots(c(0.4,-1.3,1))
abs(roots(c(0.4,-1.3,1)))

# Simmulate a time series exhibiting cyclical patterns ----
dt=1/12
t=c(1:300)*dt
cycl1=sin(2*pi*t/2)
set.seed(3)
r1=rnorm(300,sd=2.5)

y=1.5*cycl1+r1

windows()
layout(matrix(c(1,1,2,3),2,2,byrow=T))
plot(y,type="l",col="blue",lwd=2, main="",xlab="",ylab="")
acf(y,col="red",main="ACF")
pacf(y,col="red",main="PACF")

m3=arima(y, order=c(3,0,0))

windows()
#layout(matrix(c(1,1,2,3),2,2,byrow=T))
plot(y,type="l",col="blue",lwd=1, main="",xlab="",ylab="")
lines(y-m3$residuals,lwd=2,col="red")
lines(1.5*cycl1,lwd=2,col="green")
#acf(y,col="red",main="ACF of the time series")
#acf(y-m3$residuals,col="red",main="ACF of the fitted series")

rm3=roots(c(-m3$coef[3],-m3$coef[2],-m3$coef[1],1))
# Calculate the approximate cycle length
# The formula is:
# k=2*pi/cos^(-1)[Re(r)/abs(r)]
k=2*pi/acos(Re(rm3)[2]/abs(rm3)[2])
k

windows()
acf(m3$residuals,col="red",main="ACF")
#m14=arima(y, order=c(14,0,0), fixed=c(NA,NA,NA,0,0,0,0,0,0,NA,0,NA,0,NA,NA))
#windows()
#acf(m14$residuals,col="red",main="ACF")

# US gdp growth rate ----
rm(list=ls())
library(fBasics)
setwd("C:\\Users\\bpelova\\Desktop\\uni\\courses\\FinReturns\\topic2\\arma")
dd=read.csv("GDP.csv")
View(dd)
attach(dd)
# start date is Q2-1947
y=ts(gdp, frequency = 4,start=c(1947,2))
plot(y,type="l",col="blue")
# the time series seems to stationary
layout(matrix(c(1,2),nrow=1,ncol=2))
acf(y)
pacf(y)
adf.test(y,k=5)
Box.test(y,20,type="Ljung")

# Fit AR(1), AR(2), AR(3)
m1=arima(y, order=c(1,0,0))
# yhat(t)=0.0077+0.3787y(t-1)
tsdiag(m1)
# Compare ACF of original and fitted sereis
layout(matrix(c(1,2),nrow=1,ncol=2))
acf(y)
acf(y-m1$residuals)

m2=arima(y, order=c(2,0,0))
m3=arima(y, order=c(3,0,0))

names(m1)
m1$aic
m2$aic
m3$aic
m3$coef

rm3=roots(c(-m3$coef[3],-m3$coef[2],-m3$coef[1],1))
rm3

# Calculate the approximate cycle length
# The formula is:
# k=2*pi/cos^(-1)[Re(r)/abs(r)]
k=2*pi/acos(Re(rm3)[1]/abs(rm3)[1])
k
