# Generate time series ----
# Set the time step
rm(list=ls())
dt=1/12
# Trend variable
t=c(1:300)*dt
# Cycle
# Create cyclical component of 2 years length
cycl1=cos(2*pi*t/2)
windows()
plot(cycl1, type="l",col="red",lwd=2)
lines(sin(2*pi*t/2),col="green",lwd=2)
lines(sin(2*pi*t/2+pi/2),col="blue",lwd=2)
lines(sin(2*pi*t/2+pi*3/4),col="red",lwd=2)
lines(0.2*sin(2*pi*t/2+pi*3/4),col="pink",lwd=2)

# Create cyclical component of 2 years length
cycl2=cos(2*pi*t/5)
plot(cycl2, type="l")
# Generate noise vector
r0=rnorm(300)
r1=rnorm(300,sd=2)
r2=rnorm(300,sd=5)
r3=rnorm(300,sd=7.5)

# FFT ----

y1=cycl1+cycl2+r0

Y1=fft(y1)
plot(Y1)
plot(abs(Y1))

# http://195.134.76.37/applets/AppletNyquist/Appl_Nyquist2.html
fftransform=function(x,dt){
  n=length(x)
  X=fft(x)
  power=((abs(X[1:floor(n/2)]))^2)/n
  nyquist=1/2
  freq=c(1:(n/2))/(n/2)*nyquist
  period=(1/freq)*dt
  output=data.frame(period=period,freq=freq,power=power)
  return(output)
}

ft=fftransform(y1,1/12)
windows()
plot(ft$period,ft$power,type="l",col="blue",lwd=2)
ft$period[which.max(ft$power)]
