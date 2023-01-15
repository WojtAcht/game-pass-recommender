library(plumber)

r <- plumb("api.R")

games_no <<- 0.0
all_ratings  <<- 0.0
all_playtime  <<- 0.0
all_released  <<- 0.0
esrb_dict <<- list("adults-only" = 0, "mature" = 0, "teen" = 0, "everyone-10-plus" = 0, "everyone" = 0)

r$run(port = 8000, swagger = TRUE)
