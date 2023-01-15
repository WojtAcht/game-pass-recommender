source("bayesian_net.R")
# Loading package
library(plumber)

#* @filter cors
cors <- function(res) {
    res$setHeader("Access-Control-Allow-Origin", "*") # Or whatever
    plumber::forward()
}

#* Get 5 recommended games
#* @preempt cors
#* @get /api/v1/games/recommend
function() {
  game <- list(rating = all_ratings / games_no,
                esrb_rating = names(esrb_dict[order(unlist(esrb_dict))[5]]),
                playtime = all_playtime / games_no,
                released = all_released / games_no)
  games <- names(get_5_predicted_games(game))
  games_no <<- 0.0
  all_ratings  <<- 0.0
  all_playtime  <<- 0.0
  all_released  <<- 0.0
  esrb_dict <<- list("adults-only" = 0, "mature" = 0, "teen" = 0, "everyone-10-plus" = 0, "everyone" = 0)
  return(games)
}

#* Set game preference
#* @preempt cors
#* @param rating game rating
#* @param esrb_rating game esrb rating
#* @param playtime game playtime
#* @param released game release year
#* @param liked like status 1 for yes 0 for no
#* @put /api/v1/games/preference
function(rating=4.8, esrb_rating='everyone', 
  playtime=5, released=2000, liked=1) {
  # print("Setting a new preference")
  # print(rating)
  # print(esrb_rating)
  # print(playtime)
  # print(released)
  # print(liked)
  if(as.numeric(liked) == 1.0) {

    games_no <<- games_no + 1.0
    all_ratings <<- all_ratings + as.numeric(rating)
    all_playtime <<- all_playtime + as.numeric(playtime)
    all_released <<- all_released + as.numeric(released)
    esrb_dict[[esrb_rating]] <<- esrb_dict[[esrb_rating]] + 1.0

  }
  if(as.numeric(liked) == -1.0) {
    esrb_dict[[esrb_rating]] <<- esrb_dict[[esrb_rating]] - 1.0
  }
}
