:- begin_tests(random_game).
:- use_module(random_game).

all_diff(L) :- \+ (append(_,[X|R],L), memberchk(X,R)).

test(unique) :- 
    n_random_games(5, RandomGames),
    writeln(RandomGames),
    all_diff(RandomGames).

:- end_tests(random_game).