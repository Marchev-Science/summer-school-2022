# https://sites.google.com/site/aguiarconraria/joanasoares-wavelets

# This script generates the Wavelet Power pictures of
# Figure 2 in the paper by
# Lu?s Aguiar-Conraria, Pedro Magalh?es and Maria Joana Soares,
# "Cycles in Politics: Wavelet Analysis of Political Time Series",
#  American Journal of Political Science, 56(2), 500-518 

# ---------------- Series y -------------------

tin<-1:39
tmed<-40:60
tfin<-61:100
yin<-cos(2*pi*tin/3)+cos(2*pi*tin/10)
ymed<-cos(2*pi*tmed/5)+cos(2*pi*tmed/10)
yfin<-cos(2*pi*tfin/3)+cos(2*pi*tfin/10)
y<-c(yin,ymed,yfin)


#----------- Wavelet parameters --------------
dt<-1
dj<-1/50
low.period<-1
up.period<-16
# All the other parameters take dfault values (e.g., we use Morlet wavelet)

# ----------- Computation of WT  of series y -------------

WTY<-gwt(y,dt=dt,dj=dj,low.period=low.period,up.period=up.period)


#--------------  Series x   -------------------------
tin<-1:49
tfin<-50:100
xin<-cos(2*pi*tin/4)
xfin<-cos(2*pi*tfin/6)
x<-c(xin,xfin)

#----------- Wavelet parameters --------------
dj<-1/50
low.period<-1
up.period<-14
# All the other parameters take dfault values (e.g., we use Morlet wavelet)

# ----------- Computation of WT of x -------------

WTX<-gwt(x,dt=dt,dj=dj,low.period=low.period,up.period=up.period)


# ----------- Plots ------------------------------
layout(matrix(c(1,2,3,4),2,2,byrow=FALSE))


plot(y,type="l",col="blue",lwd=1.5,ylim=c(-2,2),xlab="time",ylab="",axes=FALSE,main="Series y")
axis(side=2, at=c(-2,-1,0,1,2),lab=c(-2,-1,0,1,2),las=1)
axis(side=1, at=20*seq(0,5,1),lab=20*seq(0,5,1))
grid()
box()

plot(x,type="l",col="blue",lwd=1.5,ylim=c(-2,2),xlab="time",ylab="",axes=FALSE,main="Series x")
axis(side=2, at=c(-2,-1,0,1,2),lab=c(-2,-1,0,1,2),las=1)
axis(side=1, at=20*seq(0,5,1),lab=20*seq(0,5,1))
grid()
box()


plotWT(WTY)
# Additional information on axes (adapted to this particular example)
axis(side=2,at=log2(c(1,3,5,10)),lab=c(1,3,5,10),las=1)
axis(side=1, at=20*seq(0,5,1),lab=20*seq(0,5,1))


plotWT(WTX)
# Additional information on axes (adapted to this particular example)
axis(side=2,at=log2(c(1,4,6,12)),lab=c(1,4,6,12),las=1)
axis(side=1, at=20*seq(0,5,1),lab=20*seq(0,5,1))

