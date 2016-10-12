
#include <R.h>
#include <Rinternals.h>

int add( int a, int b){
  return a + b ;
}

SEXP add_c( SEXP a_, SEXP b_){
  int a = INTEGER(a_)[0], b = INTEGER(b_)[0] ;
  
  int res = add(a, b) ;
  
  SEXP result = PROTECT(allocVector(INTSXP, 1)) ;
  INTEGER(result)[0] = res ;
  UNPROTECT(1) ;
  
  return result ;
}

