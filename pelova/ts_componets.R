# Set the time step and simulate TS ingredients ----
rm(list=ls())
dt=1/12
t=c(1:300)*dt
# Trend variable
windows()
par(mfrow=c(1,3))
plot(t,type="l",col="blue",lwd=2,main="Linear trend")
plot(t^2,type="l",col="blue",lwd=2, main="Quadratic trend")
plot(exp(t),type="l",col="blue",lwd=2, main="Exponetial trend")
# Cycle
# Create cyclical component of 2 years length
cycl1=cos(2*pi*t/2)
windows()
par(mfrow=c(1,2))
plot(t,cycl1, type="l",col="blue",lwd=2, main="Period=2 years")
# Create cyclical component of 5 years length
cycl2=cos(2*pi*t/5)
plot(t,cycl2, type="l",col="blue",lwd=2, main="Period=5 years")
# Create seasonal weigths
wgt=c(0.80, 0.85, 0.9, 0.95, 
      1,1,1,1,1,1,1.25,1.25)
season=rep(wgt,25)
# Generate noise vector
set.seed(3)
r0=rnorm(300)
r1=rnorm(300,sd=2)
r2=rnorm(300,sd=5)
r3=rnorm(300,sd=7.5)
windows()
par(mfrow=c(2,2))
plot(r0,type="l",col="blue",lwd=2,main="SD=1")
plot(r1,type="l",col="blue",lwd=2,main="SD=2")
plot(r2,type="l",col="blue",lwd=2,main="SD=5")
plot(r3,type="l",col="blue",lwd=2,main="SD=7.5")
# Simulate a time series exhibiting trend, cycles and seasonality ----
y1=(t+cycl2+cycl1)*season+r1
windows()
par(mfrow=c(2,2))
plot(cycl2+cycl1, type="l",col="blue",lwd=2,main="C1+C2")
plot(t+cycl2+cycl1, type="l",col="blue",lwd=2,main="C1+C2+T")
plot((t+cycl2+cycl1)*season, type="l",col="blue",lwd=2,main="(C1+C2+T)*S")
plot(y1, type="l",col="blue",lwd=2, main="Time series")
