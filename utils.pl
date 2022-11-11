:- module(utils,
    [
        sum/2,
        choice/3,
        build/3,
        random_game/1
    ]
).

sum([], 0).
sum([Head|Tail], Total) :- sum(Tail, Sum), Total is Head + Sum.

choice([X|_], [P|_], Cumul, Rand, X) :- Rand < Cumul + P.
choice([_|Xs], [P|Ps], Cumul, Rand, Y) :-
    Cumul1 is Cumul + P,
    Rand >= Cumul1,
    choice(Xs, Ps, Cumul1, Rand, Y).
choice([X], [P], Cumul, Rand, X) :-
    Rand < Cumul + P.
choice(Xs, Ps, Y) :- random(R), choice(Xs, Ps, 0, R, Y).

build(X, N, List)  :- 
    length(List, N), 
    maplist(=(X), List).

divide(X, Y, Z) :- Z is X / Y.

random_game(RandomGame) :-  
    findall(RatingsCount, ratings_count(G, RatingsCount), RatingsCountList),
    sum(RatingsCountList, SumOfRatings),
    length(RatingsCountList, RatingsCountListLength),
    build(SumOfRatings, RatingsCountListLength, RepeatedSumOfRatings),
    maplist(divide, RatingsCountList, RepeatedSumOfRatings, Probabilities),
    findall(G, ratings_count(G, RatingsCount), GamesList),
    choice(GamesList, Probabilities, RandomGame).