:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).
:- use_module(library(http/http_unix_daemon)).
:- use_module(games).
:- use_module(utils).
:- use_module(random_game).
:- use_module(similarity).

:- set_setting(http:cors, [*]).

:- http_server(http_dispatch, [port(6000)]).
:- http_handler('/api/v1/games', get_games(Method), [method(Method)]).
% :- http_handler('/api/v1/games/recommend', handle_suggest_moves(Method), [method(Method)]).

get_games(options, Request) :-
  cors_enable(Request, [methods([get])]),
  format('~n').

get_games(get, Request) :-
  cors_enable(Request, [methods([get])]),
  n_random_games(5, RandomGames),
  reply_json_dict(result{games: RandomGames}).
