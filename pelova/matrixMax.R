matrixMax<-function(mat,nb=2,factor=0)
{
  #  matrixMax Local maxima of a matrix.
  #
  #   MatrixMax(mat,nb,factor) 
  #   Calculates the location of the "local" maxima of the matrix mat. 
  #   In each column, every  element is compared with its neighbors up to
  #   "distance"  nb. Just the values which are larger than factor*(glob.max), 
  #   where glob.max denotes the "global" maximum of mat, are selected.
  #
  #   INPUTS: 
  #       mat - a matrix (whose local maxima we want to compute).
  #   Optional inputs:
  #       nb  - 2*nb+1 is the number of points used to compute a maximum
  #            (Default: nb=3).
  #       factor - factor of the global maximum used to select a maximum
  #             (Default: factor=0.14).
  #
  #    OUTPUT: 
  #       loc.max - a 0-1 matrix, with the same size of mat, giving the 
  #       location of the maxima (1 if the respective element is a maximum,
  #       0 otherwise).
  ###########################################################################
  #       THIS IS A  SLIGHT  MODIFICATION OF THE FUNCTION
  #
  #                       WAVELETRIDGE (written in Matlab)
  #
  #                             by
  # Bernard CAZELLES                     Mario CHAVEZ
  # Ecology-Evolution-Mathematics            LENA
  # CNRS - UMR 7625 - 2005                   CNRS - LPR 640 - 2005
  ##########################################################################

  #  Written by L. Aguiar-Conraria and M.J. Soares
  #
  #   Lu?s AGUIAR-CONRARIA              Maria Joana SOARES                      
  #   Dep. Economics                    Dep. Mathematics and Applications   
  #   University of Minho               University of Minho
  #   4710-057 Braga                    4710-057 Braga
  #   PORTUGAL                          PORTUGAL
  #                           
  #   lfaguiar@eeg.uminho.pt            jsoares@math.uminho.pt 

  ###

  if (missing(mat)){stop("Must input matrix")}
  n.rows<-nrow(mat)
  n.cols<-ncol(mat)
  Ridges <- matrix(0,n.rows,n.cols)

  globMax <- factor*max(mat); # Global maximum of the matrix, multiplied by factor

  for ( jj in (1: n.cols) ) {

	for ( ii in ( (1+nb):(n.rows-nb) ) ){
        ind.min<-ii-nb
        ind.max<-ii+nb
                
        if ( max(mat[ind.min:ind.max,jj]) == mat[ii,jj] && mat[ii,jj]>globMax ){
            Ridges[ii,jj] <- 1
           }
         }
      for ( ii in (1:nb) ){
           if ( max(mat[1:(ii+nb),jj]) == mat[ii,jj] && mat[ii,jj] > globMax )
           {
            Ridges[ii,jj] <- 1
           }
         }
     for ( ii in  ((n.rows-nb+1) : n.rows )){
      if ( max(mat[(ii-nb):n.rows,jj]) == mat[ii,jj] && mat[ii,jj] > globMax )
      {   Ridges[ii,jj] <-1
      }
}
}
                    

return(invisible(Ridges))
}
