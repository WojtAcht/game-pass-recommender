source("bayesian_net.R")
# Loading package
library(plumber)

#' @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers", 
                  req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200 
    return(list())
  } else {
    plumber::forward()
  }

}

#* Get 5 recommended games
#* @post /api/v1/games/recommend
function(req) {
  games = req$body[["games"]]
  liked = req$body[["liked"]]
  return(set_preferences_and_recommend(games, liked))
}