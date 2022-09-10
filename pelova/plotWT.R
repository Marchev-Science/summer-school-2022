plotWT<-function(WT, pE=0.5, sig.levels=FALSE, lev=c(0.05))
{     
  # To plot wavelet power, coi, ridges (and levels of sigificance)
  # INPUT:
  #  WT - output of function gwt
  # Optional input:
  #  pE - a constant to enhance the quality of picture
  #  sig.levels - if TRUE, plots levels of significance
  #  (only possible if gwt was used with n.sur>0)
  #  lev - vector with the levels of significance
     
  library(matlab) # To use jet.colors
  # Plot power
  power<-WT$power
  periods<-WT$periods
  coi<-WT$coi
  times<-1:ncol(power)
  periods<-log2(periods)
  coi<-log2(coi)
  C<-(t(power))^pE
  range.C<-range(C)
  min.lim<-range.C[1]
  max.lim<-range.C[2]

  graphics::image(times,periods,C,zlim = c(min.lim,max.lim),
                  axes=FALSE, xlab="time", ylab="periods", main="Wavelet Power",col=jet.colors(124))
  # Plot coi
  polygon(times,coi,border="red", lwd=3)

  # Plot ridges
  rid<-t(matrixMax(power,nb=3,factor=.14))
  contour(times, periods, rid, levels = 1, lwd = 1.5, 
   add = TRUE, col = "white", drawlabels = FALSE)

  # Plot levels of significance
  if(sig.levels==TRUE){
  pvPower=WT$pv
  pvPower<-t(pvPower)
  contour(times,periods,pvPower, 
          levels = lev, lwd = 0.5, add = TRUE, col = "black", drawlabels = TRUE)
    }             
} 