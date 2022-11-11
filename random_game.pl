:- module(random_game,
    [
        random_game/1,
        n_random_games/2
    ]
).

random_game(RandomGame) :-  
    findall(RatingsCount, ratings_count(G, RatingsCount), RatingsCountList),
    sum(RatingsCountList, SumOfRatings),
    length(RatingsCountList, RatingsCountListLength),
    build(SumOfRatings, RatingsCountListLength, RepeatedSumOfRatings),
    maplist(divide, RatingsCountList, RepeatedSumOfRatings, Probabilities),
    findall(G, ratings_count(G, RatingsCount), GamesList),
    choice(GamesList, Probabilities, RandomGame).

n_random_games(N, RandomGames) :- 
    n_random_games(N, [], RandomGames).
n_random_games(0, CurrentRandomGames, RandomGames) :- 
    RandomGames = CurrentRandomGames.
n_random_games(N, CurrentRandomGames, RandomGames) :- 
    random_game(G),
    N1 is N-1,
    append(CurrentRandomGames, [G], NewCurrentRandomGames),
    n_random_games(N1, NewCurrentRandomGames, RandomGamesAtoms),
    maplist(term_string, RandomGamesAtoms, RandomGames).