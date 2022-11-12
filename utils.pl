:- module(utils,
    [
        sum/2,
        choice/3,
        build/3,
        divide/3,
        vector/3,
        second/2,
        is_member/2,
        multiply_list/3,
        vectors_sum/3,
        sum_of_vectors_list/3,
        are_identical/2,
        n_largest/3,
        string_term/2
    ]
).

sum([], 0).
sum([Head|Tail], Total) :- sum(Tail, Sum), Total is Head + Sum.

% Works as numpy.random.choice.
% https://stackoverflow.com/questions/50250234/prolog-how-to-non-uniformly-randomly-select-a-element-from-a-list
choice([X|_], [P|_], Cumul, Rand, X) :- Rand < Cumul + P.
choice([_|Xs], [P|Ps], Cumul, Rand, Y) :-
    Cumul1 is Cumul + P,
    Rand >= Cumul1,
    choice(Xs, Ps, Cumul1, Rand, Y).
choice([X], [P], Cumul, Rand, X) :-
    Rand < Cumul + P.
choice(Xs, Ps, Y) :- random(R), choice(Xs, Ps, 0, R, Y).

% Create list with X repeated N times.
build(X, N, List)  :- 
    length(List, N), 
    maplist(=(X), List).

n_largest(L, N, R) :-
    msort(L, LS),
    length(R, N),
    append(_, R, LS).

vector(X,Y,Z) :- Z = [X,Y].

% Inspiration: https://clojuredocs.org/clojure.core/second
second(X,Y) :- nth0(1, X, Y).

multiply(X,Y,Z) :- Z is X*Y.
multiply_list(List,X,Result) :- maplist(multiply(X), List, Result).

vectors_sum(V1, V2, Result) :- vectors_sum(V1, V2, [], Result).
vectors_sum([], [], CurrentResult, Result) :- Result = CurrentResult.
vectors_sum([H1|T1], [H2|T2], CurrentResult, Result) :- 
    H is H1+H2,
    append(CurrentResult, [H], NewCurrentResult),
    vectors_sum(T1, T2, NewCurrentResult, Result).

sum_of_vectors_list([], CurrentResult, Result) :- 
    Result = CurrentResult.
sum_of_vectors_list([V | T], CurrentResult, Result) :-
    vectors_sum(V, CurrentResult, NewCurrentResult),
    sum_of_vectors_list(T, NewCurrentResult, Result).

divide(X, Y, Z) :- Z is X / Y.
is_member(List, Element) :- member(Element, List).
are_identical(X, Y) :- X == Y.

string_term(X,Y) :- term_string(Y,X).