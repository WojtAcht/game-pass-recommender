library(bnlearn)
library(gRain)

rawg <- read.csv("rawg.csv")
rawg[rawg["esrb_rating"] == "", ]["esrb_rating"] <- NA 

sorted_esrb_ratings <- c("adults-only", "mature", "teen", "everyone-10-plus", "everyone")
esrb_ratings <- unique(rawg$esrb_rating)
esrb_ratings <- esrb_ratings[!is.na(esrb_ratings)]
esrb_ratings_distribution <- table(rawg$esrb_rating) / sum(table(rawg$esrb_rating))

get_esrb_probability <- function(esrb_rating, game) {
  game_esrb_rating <- game$esrb_rating
  game_esrb_rating_idx <- match(game_esrb_rating, sorted_esrb_ratings)
  esrb_rating_idx <- match(esrb_rating, sorted_esrb_ratings)
  if(is.na(game_esrb_rating_idx) || is.na(esrb_rating_idx)) {
    return(as.vector(esrb_ratings_distribution[[esrb_rating]]))
  }
  else {
    esrb_ratings_distance <- abs(esrb_rating_idx - game_esrb_rating_idx)
    unknown_rating_probability <- esrb_ratings_distribution["rating-pending"]
    distance_nonlinear <- function(distance) { 2^(1-distance) }
    normalization_value <- sum(distance_nonlinear(abs(1:length(sorted_esrb_ratings) - game_esrb_rating_idx)))
    probability <- distance_nonlinear(esrb_ratings_distance) / normalization_value
    return(probability * (1 - unknown_rating_probability))
  }
}

ratings <- seq(0, 5, 0.25)
get_rating_probabilities <- function(game) {
  game_rating <- game$rating 
  dnorm_values <- dnorm(ratings, mean=game_rating, sd=0.25)
  dnorm_values / sum(dnorm_values)
}

playtime_larger_than_5 <- c(F, T)
get_playtime_probabilities <- function(game) {
  game_playtime <- game$playtime
  if(game$playtime < 5){
    return(c(0.8, 0.2))
  }
  else{
    return(c(0.1, 0.9))
  }
}

released_years <- seq(1990, 2022, 5)
get_released_probabilities <- function(game) {
  game_released_year <- as.integer(substr(game$released, 1, 4))
  dnorm_values <- dnorm(released_years, mean = game_released_year, sd = 5)
  dnorm_values / sum(dnorm_values)
}


esrb_probabilities <- c()
for(rowname in rownames(rawg)){
  row <- rawg[rowname, ]
  for(esrb_rating in esrb_ratings) {
    esrb_probabilities <- c(esrb_probabilities, get_esrb_probability(esrb_rating, row))
  }
}

rating_probabilities <- c()
for(rowname in rownames(rawg)){
  row <- rawg[rowname, ]
  rating_probabilities <- c(rating_probabilities, get_rating_probabilities(row))
}

playtime_probabilities <- c()
for(rowname in rownames(rawg)){
  row <- rawg[rowname, ]
  playtime_probabilities <- c(playtime_probabilities, get_playtime_probabilities(row))
}

released_probabilities <- c()
for(rowname in rownames(rawg)){
  row <- rawg[rowname, ]
  released_probabilities <- c(released_probabilities, get_released_probabilities(row))
}

dag = model2network("[ESRB|G][RATING|G][PLAYTIME|G][RELEASED|G][G]")
G.lv <- rawg$slug
G.prob <- array(
  # Uniform prior distribution for G
  rep(1/length(G.lv), times=length(G.lv)), 
  dim = length(G.lv), 
  dimnames = list(G = G.lv)
)

ESRB.lv <- esrb_ratings
ESRB.prob <- array(
  esrb_probabilities, 
  dim = c(length(ESRB.lv), length(G.lv)), 
  dimnames = list(ESRB = ESRB.lv, G = G.lv)
)

RATING.lv <- ratings
RATING.prob <- array(
  rating_probabilities, 
  dim = c(length(RATING.lv), length(G.lv)), 
  dimnames = list(RATING = RATING.lv, G = G.lv)
)

PLAYTIME.lv <- playtime_larger_than_5
PLAYTIME.prob <- array(
  playtime_probabilities, 
  dim = c(length(PLAYTIME.lv), length(G.lv)), 
  dimnames = list(PLAYTIME = PLAYTIME.lv, G = G.lv)
)

RELEASED.lv <- released_years
RELEASED.prob <- array(
  released_probabilities, 
  dim = c(length(RELEASED.lv), length(G.lv)), 
  dimnames = list(RELEASED = RELEASED.lv, G = G.lv)
)

cpt <- list(
  G = G.prob,
  ESRB = ESRB.prob, 
  PLAYTIME = PLAYTIME.prob,
  RATING = RATING.prob,
  RELEASED = RELEASED.prob
)

bn <- custom.fit(dag, cpt)
junction <- compile(as.grain(bn))

get_5_predicted_games <- function(game) {
  state_rating <- as.character(round(game$rating * 4) / 4)
  j_game <- setEvidence(junction, nodes = "RATING", states = state_rating)
  if(!is.na(game$esrb_rating)) {
    j_game <- setEvidence(j_game, nodes = "ESRB", states = game$esrb_rating)
  }
  state_playtime <- as.character(game$playtime > 5)
  j_game <- setEvidence(j_game, nodes = "PLAYTIME", states = state_playtime)
  released_year <- as.integer(substr(game$released, 1, 4))
  state_released <- released_years[round((released_year - 1990) / 5) + 1]
  state_released <- as.character(state_released)
  j_game <- setEvidence(j_game, nodes = "RELEASED", states = state_released)
  # Returns named vector - to obtain slug values use: names(get_5_predicted_games(game))
  return(sort(querygrain(j_game, nodes = "G")$G, decreasing=T)[1:5])
}

set_preference <- function(game_slug, liked) {
  game <- rawg[rawg$slug == game_slug, ]
  if(as.numeric(liked) == 1.0) {
    games_no <<- games_no + 1.0
    all_ratings <<- all_ratings + as.numeric(game$rating)
    all_playtime <<- all_playtime + as.numeric(game$playtime)
    all_released <<- all_released + as.integer(substr(game$released, 1, 4))
    esrb_dict[[game$esrb_rating]] <<- esrb_dict[[game$esrb_rating]] + 1.0
  }
  if(as.numeric(liked) == -1.0) {
    esrb_dict[[game$esrb_rating]] <<- esrb_dict[[game$esrb_rating]] - 1.0
  }
}

map_game <- function(game_slug) {
  game <- rawg[rawg$slug == game_slug, ]
  ls <- list("id"= game$slug, "name"= game$name)
  return(ls)
}

set_preferences_and_recommend <- function(games_list, liked_list) {

  games_no <<- 0.0
  all_ratings  <<- 0.0
  all_playtime  <<- 0.0
  all_released  <<- 0.0
  esrb_dict <<- list("adults-only" = 0, "mature" = 0, "teen" = 0, 
                      "everyone-10-plus" = 0, "everyone" = 0)

  for (i in 1:length(games_list)) {
    set_preference(games_list[[i]], liked_list[[i]])
  }

  game <- list(rating = all_ratings / games_no,
                esrb_rating = names(esrb_dict[order(unlist(esrb_dict))[5]]),
                playtime = all_playtime / games_no,
                released = all_released / games_no)
  games <- names(get_5_predicted_games(game))

  recommended_games = list("games" = list())
  for(i in 1:length(games)) {
    recommended_games[[1]][[i]] <- map_game(games[[i]])
  }
  return(recommended_games)
}
