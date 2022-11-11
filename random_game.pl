:- module(random_game,
    [
        n_random_games/2
    ]
).

random_game_slug(RandomGame) :-  
    findall(RatingsCount, ratings_count(G, RatingsCount), RatingsCountList),
    sum(RatingsCountList, SumOfRatings),
    length(RatingsCountList, RatingsCountListLength),
    build(SumOfRatings, RatingsCountListLength, RepeatedSumOfRatings),
    maplist(divide, RatingsCountList, RepeatedSumOfRatings, Probabilities),
    findall(G, ratings_count(G, RatingsCount), GamesList),
    choice(GamesList, Probabilities, RandomGame).

n_random_game_slugs(N, RandomGames) :- 
    n_random_game_slugs(N, [], RandomGames).
n_random_game_slugs(0, CurrentRandomGames, RandomGames) :- 
    RandomGames = CurrentRandomGames.
n_random_game_slugs(N, CurrentRandomGames, RandomGames) :- 
    random_game_slug(G),
    N1 is N-1,
    append(CurrentRandomGames, [G], NewCurrentRandomGames),
    n_random_game_slugs(N1, NewCurrentRandomGames, RandomGames).

game(Id, Image, Name, Game) :-
    Game = game{id: Id, name: Name, image: Image}.

n_random_games(N, RandomGames) :-
    n_random_game_slugs(N, RandomGameSlugs),
    maplist(term_string, RandomGameSlugs, RandomGameStrings),
    maplist(name, RandomGameSlugs, RandomGameNames),
    maplist(image, RandomGameSlugs, RandomGameImages),
    maplist(game, RandomGameStrings, RandomGameImages, RandomGameNames, RandomGames).
    