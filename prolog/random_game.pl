:- module(random_game,
    [
        n_random_games/2,
        game/2
    ]
).

:- use_module(games).
:- use_module(utils).

random_game_id(RandomGameId) :-  
    findall(RatingsCount, ratings_count(G, RatingsCount), RatingsCountList),
    sum(RatingsCountList, SumOfRatings),
    length(RatingsCountList, RatingsCountListLength),
    build(SumOfRatings, RatingsCountListLength, RepeatedSumOfRatings),
    maplist(divide, RatingsCountList, RepeatedSumOfRatings, Probabilities),
    findall(G, ratings_count(G, RatingsCount), GamesList),
    choice(GamesList, Probabilities, RandomGameId).

n_random_game_ids(N, RandomGameIds) :- 
    n_random_game_ids(N, [], RandomGameIds).
n_random_game_ids(0, CurrentRandomGameIds, RandomGameIds) :- 
    RandomGameIds = CurrentRandomGameIds.
n_random_game_ids(N, CurrentRandomGameIds, RandomGameIds) :- 
    random_game_id(G),
    \+ member(G, CurrentRandomGameIds),
    N1 is N-1,
    append(CurrentRandomGameIds, [G], NewCurrentRandomGameIds),
    n_random_game_ids(N1, NewCurrentRandomGameIds, RandomGameIds).

game(Id, Game) :-
    name(Id, Name),
    image(Id, Image),
    term_string(Id, StringId),
    Game = game{id: StringId, name: Name, image: Image}.

n_random_games(N, RandomGames) :-
    n_random_game_ids(N, RandomGameIds),
    maplist(game, RandomGameIds, RandomGames).
    