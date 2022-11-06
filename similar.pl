% Run [games]. before

similar_year_rating(Movie_a, Movie_b) :- 
    esrb_rating(Movie_a, C), 
    esrb_rating(Movie_b, B), 
    C == B.

similar_genre(Movie_a, Movie_b) :- 
    genre(Movie_a, C), 
    genre(Movie_b, B), 
    C == B.

similar_playtime(Movie_a, Movie_b) :-
    playtime(Movie_a, C), 
    playtime(Movie_b, B), 
    C-B < 5,
    B-C < 5.

similar_rating(Movie_a, Movie_b) :-
    rating(Movie_a, C), 
    rating(Movie_b, B), 
    C-B < float(0.7),
    B-C < float(0.7).

similar_ratings_count(Movie_a, Movie_b) :-
    ratings_count(Movie_a, C), 
    ratings_count(Movie_b, B), 
    C-B < 500,
    B-C < 500.