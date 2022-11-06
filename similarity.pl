genre_coefficient(Game1, Game2, GenreCoefficient) :- 
    setof(Genre1, Genre1^genre(Game1, Genre1), Game1Genres), 
    setof(Genre2, Genre2^genre(Game2, Genre2), Game2Genres), 
    intersection(Game1Genres, Game2Genres, CommonGenres),
    length(Game1Genres, Game1GenresLength),
    length(Game2Genres, Game2GenresLength),
    length(CommonGenres, CommonGenresLength),
    GenreCoefficient is (2 * CommonGenresLength) / (Game1GenresLength + Game2GenresLength),
    !.

genre_coefficient(_, _, GenreCoefficient) :- 
    GenreCoefficient = 0.

esrb_rating_coefficient(Game1, Game2, ESRBCoefficient) :- 
    esrb_rating(Game1, Rating1),
    esrb_rating(Game2, Rating2),
    nth0(Rating1Index, [mature, adults-only, teen, everyone-10-plus, everyone], Rating1),
    nth0(Rating2Index, [mature, adults-only, teen, everyone-10-plus, everyone], Rating2),
    ESRBCoefficient is 1 - abs(Rating2Index - Rating1Index) / 4,
    !.

esrb_rating_coefficient(_, _, ESRBCoefficient) :- 
    ESRBCoefficient = 0.

released_coefficient(Game1, Game2, ReleasedCoefficient) :-
    released(Game1, Game1Released),
    released(Game2, Game2Released),
    split_string(Game1Released, "-", "", Game1Date), 
    split_string(Game2Released, "-", "", Game2Date),     
    nth0(0, Game1Date, YearString1), 
    nth0(0, Game2Date, YearString2), 
    number_string(Year1, YearString1),
    number_string(Year2, YearString2),
    ReleasedYearsDifference is abs(Year2 - Year1),
    ReleasedCoefficient is e**(-1*ReleasedYearsDifference/8),
    !.

released_coefficient(_, _, ReleasedCoefficient) :-
    ReleasedCoefficient = 0.

playtime_coefficient(Game1, Game2, PlaytimeCoefficient) :- 
    playtime(Game1, Playtime1),
    playtime(Game2, Playtime2),
    Playtime1 > 20,
    Playtime2 > 20,
    PlaytimeCoefficient is 1,
    !.

playtime_coefficient(Game1, Game2, PlaytimeCoefficient) :- 
    playtime(Game1, Playtime1),
    playtime(Game2, Playtime2),
    Playtime1 < 5,
    Playtime2 < 5,
    PlaytimeCoefficient is 1,
    !.

playtime_coefficient(Game1, Game2, PlaytimeCoefficient) :- 
    playtime(Game1, Playtime1),
    playtime(Game2, Playtime2),
    PlaytimeCoefficient is 1 - abs(Playtime2 - Playtime1)/46,
    !.

playtime_coefficient(_, _, PlaytimeCoefficient) :-
    PlaytimeCoefficient = 0.

rating_coefficient(Game1, Game2, RatingCoefficient) :-
    rating(Game1, Rating1), 
    rating(Game2, Rating2),
    RatingCoefficient is 1 - abs(Rating2 - Rating1) / 5,
    !.

rating_coefficient(_, _, RatingCoefficient) :-
    RatingCoefficient = 0.

similarity_coefficient(Game1, Game2, SimilarityCoefficient) :- 
    genre_coefficient(Game1, Game2, Genre),
    esrb_rating_coefficient(Game1, Game2, ESRB),
    released_coefficient(Game1, Game2, Released),
    playtime_coefficient(Game1, Game2, Playtime),
    rating_coefficient(Game1, Game2, Rating),
    WeightedGenre is Genre*3,
    WeightedRating is Rating*2,
    WeightSum is 8,
    SimilarityCoefficient is (WeightedGenre+ESRB+Released+Playtime+WeightedRating)/WeightSum,
    !.

% similarity_coefficient(battlefield-3, mass-effect-2, X).