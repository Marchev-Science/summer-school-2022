gwt <- function(x,dt=1,dj=0.25,low.period=2*dt,up.period=length(x)*dt,
                 pad=0,sigma=1,n.sur=0,p=0,q=0)
{
  # Gabor Wavelet Transform Analysis of a given series (vector)
  #   
  #
  #
  #   INPUTS:
  #       x - vector (time-series).
  #
  #   Optional inputs: 
  #       dt - sampling rate (Default: 1)
  #       dj - frequency resolution 
  #            (i.e. 1/dj = number of voices per octave)
  #                   (Default: 0.25)
  #       low.period - lower period of decomposition 
  #                   (Default: 2*dt)
  #       up.period - upper period of decomposition
  #                  (Default: length(x)*dt)
  #       pad - an integer (power of 2) defining the total length of 
  #            the vector x after zero padding. 
  #            If pad is not a power of 2, pad 
  #            with zeros to total length : 2^(next power of 2 + 2)
  #       sigma - the sigma parameter for the Gabor wavelet 
  #               (Default: 1.0 - corresponds to the Morlet wavelet)         
  #       n.sur - integer, number of surrogate series, if we want to
  #              compute  p-values for the Wavelet Power Spectrum 
  #                (Default: 0 - no computation)            
  #       p,q -  non-negative integers, orders of the ARMA(P,Q) used to
  #             create the surrogates   
  #  OUTPUTS:
  #       wt - Wavelet Transform Matrix 
  #          (number of  rows = number of scales used; number of  columns = length(x))
  #       periods - the vector of Fourier periods (in time units) that
  #           correspond to the the scales used
  #       scales - the vector of scales, given by x= s0*2^(j*dj); j=0,...,J1,
  #              where J1+1 is  number of scales and s0 is 
  #              the minimum scale
  #       coi - the "cone-of-influence", which is a vector of the same 
  #           length as x that contains the limit of the region where 
  #           the wavelet transform is influenced by edge effects
  #       power -  Wavelet Power Spectrum (i.e. abs(wt)^2)
  #       pv - p-values for Wavelet Power Spectrum (only computed if n.sur>0)
  #
  #   References:
  #   [1] Aguiar-Conraria, L. and Soares, M.J. (2010)
  #       "The Continuous Wavelet Transform: A Primer",
  #        NIPE Working paper
  #   
  #   [2] Torrence, C. and Compo, T.C., "A Prectical Guide to Wavelet 
  # 	    Analysis" (1998), Bulletin of the American Meteorological 
  #       Society, 79, 605?618.
  # 
  #
  #   Copyright 2011, L. Aguiar-Conraria and M.J. Soares
  #
  #   Lu?s AGUIAR-CONRARIA         Maria Joana SOARES                      
  #   Dep. Economics               Dep. Mathematics Applications   
  #   University of Minho          University of Minho
  #   4710-057 Braga               4710-057 Braga
  #   PORTUGAL                     PORTUGAL
  #
  #   lfaguiar@eeg.uminho.pt       jsoares@math.uminho.pt 

########################################################

  # Tests on inputs
  if (missing(x)) {
    stop("must input series")}

  if (!(is.numeric(x) && is.vector(x))) {
        stop(sprintf("argument %s must be a vector", sQuote("x")))
    }
  nTimes <- length(x)

  #------- Computation of quantities that depend on the wavelet -----
  #                 (i.e. of the value of sigma)               #
  #
  # Computation of center-frequency (i.e. omega_0) - to guarantee that             
  # we have an "analytical wavelet" 
  if (sigma==1){
  center.frequency=6.0  # No need to compute
                      # This corresponds to Morlet with omega_0=6.
    } else {
            tol<- 5e-8 # May be changed, if we wish
            ck<- tol/(sqrt(2)*pi^(0.25))
            center.frequency<- sqrt(2)*(sqrt(log(sqrt(sigma))-log(ck)))/sigma
            center.frequency=ceiling(center.frequency) # choose an integer center.frequency
            }
  # Computation of Fourier factor 
  fourier.factor<- (2*pi)/center.frequency

  # Computation of radius in time
  sigma.time<-sigma/sqrt(2)
#---------------------------------------------------------------------

# ------------------------ Padding ------------------------------
# Computation of extra.length (number of zeros used to pad x with; 
# it depends on PAD)
if ( (pad > 0) && (log2(pad)%%1 ==0) )
{
	# Zero padding to selected size
	pot2 <- log2(pad);
	extra.length <- 2^pot2-nTimes
	if (extra.length <=0){
	 print("PAD smaller than size of series; next power of 2 used")
	# Zero padding to size=next power of 2+2
	pot2 <- ceiling(log2(nTimes))
	extra.length <- 2^(pot2+2)-nTimes
}
	                     
} else {
	# Zero padding to size=next power of 2+2
	pot2 <- ceiling(log2(nTimes))
	extra.length <- 2^(pot2+2)-nTimes   
}

# ------ Computation of SCALES and PERIODS -------------------------
s0<- low.period/fourier.factor # Convert low.period to minimum scale 

if (up.period>nTimes*dt){
	print("up.period is too long; it will be adapted")
	up.period<- nTimes*dt
                    }
up.scale=up.period/fourier.factor     # Convert up.period to maximum scale 
J = as.integer(log2(up.scale/s0)/dj)  # Index of maximum scale
    
scales <- s0*2^((0:J)*dj) # Vector of scales 
nScales <- length(scales)
periods <- fourier.factor*scales # Conversion of scales to periods

# ----------- Computation of COI ------------------------------------
coiS<- fourier.factor/sigma.time # 
coi<-  coiS*dt*c(1e-8,1:floor((nTimes-1)/2),floor((nTimes-2)/2):1,1e-8)

#------- Computation of angular frequencies -------------------------
N <- nTimes+extra.length
wk <- 1:floor(N/2)
wk <-  wk*(2*pi)/(N*dt)
wk<-  c(0., wk, -wk[floor((N-1)/2):1])


#-------------------------------------------------------------------
#            FUNCTION GABOR.WTRANSFORM  
#            computes wavelet transform                          
#-------------------------------------------------------------------
gabor.wtransform <- function(x)
  { x<-(x-mean(x))/sd(x)                                    
    xn<-c(x,rep(0,extra.length)) # Pad x with zeros
    # Computation of Fast Fourier Transform of xn #
    ftxn <- fft(xn)
    # Computation of Wavelet Transform of x   #
    wave <- matrix(0,nScales,N) # Matrix to accomodate WT                          
    wave <- wave + 1i*wave;      # Make it complex
    for (iScales in (1:nScales))
       { # Do the computation for each scale
         # (at all times simultaneously)
         scaleP <- scales[iScales] # Particular scale 
         norm <- pi^(1/4)*sqrt(2*sigma*scaleP/dt)
         expnt <- -( ((scaleP*wk-center.frequency)*sigma)^2/2) *(wk > 0)
         daughter <- norm*exp(expnt)
         daughter<- daughter*(wk>0)
         wave[iScales,] <- (fft(ftxn*daughter,inv=TRUE))/length(xn)
       }	
    # Truncate WT to correct size 
    wave<- wave[,1:nTimes]
    return(wave)
  }                                 
# --------  END OF  FUNCTION GABOR.WTRANSFORM  --------

       
#------ Computation of WT (matrix with Wavelet Transform)----
# (uses function gabor.wtransform)
 
  WT <- gabor.wtransform(x) 

#  -------   Computation of POWER -----------------
# (Wavelet Power Spectrum)

 power<- Mod(WT)^2 
 
#---------------------------------------------------
#     This part is only computed if n.sur>0
#----------------------------------------------------

# Compuation of pvPower                             
# uses functions arima and arima.sim from package stats
if (n.sur>0){
        pvPower <- matrix(0,dim(WT)[1],dim(WT)[2])
        for (iSur in (1:n.sur))
        {
         if(p==0&q==0){
         xSur <-rnorm(nTimes)
         } else 
        {
         fit<-stats::arima(x,order=c(p,0,q))
         coefs<-coef(fit)
         if (p==0)
            {
             ar.coefs<-c(0)
             ma.coefs<-coefs[1:q]
             } else {ar.coefs<-coefs[1:p]
                     if (q==0)
                     { ma.coefs<-c(0) } else 
                     { ma.coefs<-coefs[(p+1):(p+q)]}
                     }
         model<-list(ar=ar.coefs,ma=ma.coefs)
         xSur <-stats::arima.sim(model,nTimes)
        }
        wtSur<-gabor.wtransform(xSur)
        powerSur <- (Mod(wtSur))^2
        pvPower[which(powerSur>=power)] <- pvPower[which(powerSur>=power)]+1
	 	  }   					   
         pvPower <- pvPower/n.sur
           } 

output<-list(wt=WT,periods=periods,scales=scales,coi=coi,power=power)

if (n.sur>0){
output<-c(output,list(pv=pvPower))
}

     
return(output)

}


