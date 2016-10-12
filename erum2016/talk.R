library("dplyr")
library("tibble")
library("magrittr")

all_packages <- devtools:::cran_packages()

direct <- revdep("Rcpp")
cat( direct, file = "direct.txt" )
length(direct)
length(direct) / nrow(all_packages)

recursive <- revdep("Rcpp", recursive = TRUE)
cat( recursive, file = "recursive.txt" )
length(recursive)
length(recursive) / nrow(all_packages)


nlines <- function( where = "inst/include", pattern = ".h$"){
  files <- list.files( paste0("~/git/Rcpp/", where), pattern = pattern, recursive = TRUE, full.names = TRUE )
  sum( sapply(files, . %>% readLines(warn=FALSE) %>% length) )
} 
nlines( "inst/include", pattern = "[.]h$" ) + nlines("src", pattern = "[.]h$")
nlines( "src", pattern = "[.]cpp$")
nlines( "R", pattern = "[.]R$")