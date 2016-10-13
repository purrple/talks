library("ggplot2")
library("dplyr")
library("plyr")

get_git_loc <- function( id = "Rcpp11/Rcpp11", filter ){
  repo <- sub( "^.*/", "", id )  
  
  owd <- setwd( tempdir() )
  on.exit( setwd(owd) )
  if( file.exists(repo) ) unlink(repo, recursive = TRUE)  
  system( sprintf( "git clone -q https://github.com/%s.git", id) )    
  setwd( repo )
  
  # -- grab the ids for each commit in the repo
  commit_ids <- llply( 
    strsplit(system('git rev-list --all --pretty=oneline', intern = TRUE), '\n'), 
    function (line) {
      strsplit(line, ' ')[[1]][1]
    }, 
    .progress = "text"
  )
  
  # -- your head will usually be the most recent commit, so checkout most recent commit first.
  
  current_HEAD <- commit_ids[[1]]
  system(paste0('git checkout -q ', current_HEAD))
  
  # if you have lots of commits or are testing adjust this slice to 1..100 or something similar
  commit_ids <- commit_ids[1:length(commit_ids)]
  
  ls_cmd <- if( missing(filter) ){
    'git ls-files | xargs wc -l'
  } else {
    sprintf('git ls-files | grep "%s" | xargs wc -l', filter)
  }
  
  commit_info <- llply(commit_ids, function (id) {
    
    invisible( system(paste0('git checkout -q ', id)) )
    
    # -- get information on the version controlled lines of code
    all_lines <- system(ls_cmd, intern = TRUE)
    lines <- strsplit(all_lines, '\n')
    
    # get the number giving the lines of code
    lines_of_code <- if( length(lines) ){
      as.numeric(gsub('[^0-9]', '', lines[[length(lines)]]))
    } else {
      0  
    }
    
    # get the date of the current commit
    date  <- as.POSIXct(as.numeric( system(paste('git show -s --format=%ct', id), intern = TRUE) ), origin = "1970-01-01" )
    msg   <- paste( system("git show -s --format=%B", intern = TRUE), collapse = " " )
    data.frame(lines = lines_of_code, time = date, id = id, msg = msg, stringsAsFactors = FALSE)
  }, .progress = "text")
  
  bind_rows(commit_info) %>% 
    filter(lines > 0, !is.na(time)) 
}

Rcpp11 <- get_git_loc( "Rcpp11/Rcpp11", filter = "h$" )
Rcpp   <- get_git_loc( "RcppCore/Rcpp", filter = "h$" )

data   <- bind_rows( 
  cbind(Rcpp11, impl = "Rcpp11", stringsAsFactors = FALSE), 
  cbind(Rcpp, impl = "Rcpp" , stringsAsFactors = FALSE) 
)
# just avoiding last spike due to git 
data   <- filter( data, id != "21e9666c6b7b2154be3c28e55251965eb2a42662" )

print(
  ggplot(data, aes(time, lines, by = impl, colour = impl) ) + geom_line(size = 2)
)
