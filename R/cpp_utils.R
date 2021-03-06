#######################################################################
#                                                                     #
# Package: onemap                                                     #
#                                                                     #
# File: cpp_utils.R                                                   #
# Contains: get_bins                                                  #
# These functions are for internal use only                           #
#                                                                     #
# Written Marcelo Mollinari                                           #
#                                                                     #
# First version: 09/2015                                              #
# Last update: 01/2016                                                #
# License: GNU General Public License version 2 (June, 1991) or later #
#                                                                     #
#######################################################################

# This function calls C++ routine to find markers with redundant information
get_bins <- function(geno, exact=TRUE)
{
  bins<-.Call("get_bins",
              geno,
              as.numeric(exact),
              options()$width-6,
              PACKAGE = "onemap" )
  return(bins)
}

# This function calls C++ routine for two-point analysis (outcross)
est_rf_out<-function(geno, mrk=0, seg_type=NULL, nind, verbose=TRUE)
{
  r<-.Call("est_rf_out_wrap",
           geno,
           mrk=mrk-1,
           as.numeric(seg_type),
           as.numeric(nind),
           as.numeric(verbose),
           PACKAGE = "onemap" )

  if(mrk <= 0)
  {
      names(r)<-c("CC", "CR", "RC", "RR")
      for(i in 1:4) dimnames(r[[i]])<-list(colnames(geno), colnames(geno))
      return(r)
  }
  else
  {
      rownames(r[[1]])<-c("rCC", "rCR", "rRC", "rRR")
      colnames(r[[1]])<-colnames(geno)
      rownames(r[[2]])<-c("LODCC", "LODCR", "LODRC", "LODRR")
      colnames(r[[2]])<-colnames(geno)
      return(r)
  }
}

# This function calls C++ routine for two-point analysis (F2)
est_rf_f2<-function(geno, mrk=0, seg_type=NULL, nind, verbose=TRUE)
{
    r<-.Call("est_rf_f2_wrap",
             geno,
             mrk-1,
             as.numeric(seg_type),
             as.numeric(nind),
             as.numeric(verbose),
             PACKAGE = "onemap" )
    if(mrk <= 0)
        dimnames(r)<-list(colnames(geno), colnames(geno))
    else
        dimnames(r)<-list(c("rf", "LOD"), colnames(geno))
    return(r)
}

# This function calls C++ routine for two-point analysis (bc)
est_rf_bc<-function(geno, mrk=0,  nind, type=0, verbose=TRUE)
{
    r<-.Call("est_rf_bc_wrap",
             geno,
             mrk-1,
             as.numeric(nind),
             as.numeric(type), #0=bc; 1=riself; 2=risib
             as.numeric(verbose),
             PACKAGE = "onemap" )
    if(mrk <= 0)
        dimnames(r)<-list(colnames(geno), colnames(geno))
    else
        dimnames(r)<-list(c("rf", "LOD"), colnames(geno))
    return(r)
}

# This function calls C++ routine for multipoint analysis (f2)
est_map_hmm_f2<-function(geno, rf.vec=NULL, verbose=TRUE, tol=1e-6)
{
    if(length(rf.vec) != (nrow(geno)-1))
        rf.vec = rep(0.1, (nrow(geno)-1))
    r<-.Call("est_hmm_f2",
             geno,
             as.numeric(rf.vec),
             as.numeric(verbose),
             as.numeric(tol),
             PACKAGE = "onemap" )
    names(r)<-c("rf", "loglike") 
    return(r)
}

# This function calls C++ routine for multipoint analysis (bc)
est_map_hmm_bc<-function(geno, rf.vec=NULL, verbose=TRUE, tol=1e-6)
{
    if(length(rf.vec) != (nrow(geno)-1))
        rf.vec = rep(0.1, (nrow(geno)-1))
    r<-.Call("est_hmm_bc",
             geno,
             as.numeric(rf.vec),
             as.numeric(verbose),
             as.numeric(tol),
             PACKAGE = "onemap" )
    names(r)<-c("rf", "loglike") 
    return(r)
}

# 


##' C++ routine for multipoint analysis in outcrossing populations
##'
##' It calls C++ routine that implements the methodology of Hidden
##' Markov Models (HMM) to construct multipoint linkage maps in
##' outcrossing species
##' 
##' @param geno matrix of genotypes. Rows represent marker and columns
##'     represent individuals.
##'
##' @param type a vector indicating the type of marker. For more
##'     information see \code{\link[onemap]{read_onemap}}
##'
##' @param phase a vector indicating the linkage phases between
##'     markers. For more information see
##'     \code{\link[onemap]{make_seq}}
##'
##' @param rf.vec a vector containing the recombination fraction
##'     initial values
##'
##' @param verbose If \code{TRUE}, print tracing information.
##' 
##' @param tol tolerance for the C routine, i.e., the value used to
##'     evaluate convergence.
##' 
##' @return a list containing the re-estimated vector of recombination
##'     fractions and the logarithm of the likelihood
##'
##' @keywords internal
##'
##' @export
est_map_hmm_out<-function(geno, type,  phase, rf.vec=NULL, verbose=TRUE, tol=1e-6)
{
  if(is.null(rf.vec))
    rf.vec<-rep(0.1, (nrow(geno)-1))
  r<-.Call("est_hmm_out",
           geno,
           as.numeric(type),
           as.numeric(phase),
           as.numeric(rf.vec),
           as.numeric(verbose),
           as.numeric(tol),
           PACKAGE = "onemap")
  names(r)<-c("rf", "loglike") 
  return(r)
}
#end of the file

