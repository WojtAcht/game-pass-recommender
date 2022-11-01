import requests as re
import pickle
import os

KEY = os.getenv('RAWG_API_KEY')
PAGE_SIZE = 40

def get_xbox_platforms_ids():
    platforms_response = re.get(f"https://api.rawg.io/api/platforms?key={KEY}")
    platforms = platforms_response.json()['results']
    xbox_platforms_ids = [platform["id"] for platform in platforms if 'Xbox' in platform['name']]
    platforms_ids = ','.join([str(id) for id in xbox_platforms_ids])
    return platforms_ids

def get_games(platforms_ids, page=1):
    games_response = re.get(f"https://api.rawg.io/api/games?page=1&key={KEY}&platforms={platforms_ids}&page_size={PAGE_SIZE}&page={page}")
    games = games_response.json()
    if "results" not in games:
        return []
    elif len(games["results"]) == PAGE_SIZE:
        return games["results"] + get_games(platforms_ids, page+1)
    else:
        return games["results"]

def read_game_pass_names(file_name):
    with open(file_name, 'r') as file:
        text = file.read()
    return [name.strip().lower().replace("’", "'") for name in text.split("\n") if name]

def get_games_from_rawg():
    platforms_ids = get_xbox_platforms_ids()
    xbox_games = get_games(platforms_ids)
    with open('xbox_games.pkl', 'wb') as pickle_file:
        pickle.dump(xbox_games, pickle_file, protocol=pickle.HIGHEST_PROTOCOL)
    return xbox_games

def get_games_from_file():
    game_pass_games_names = read_game_pass_names("game_pass_games_list.txt")
    out = open("xbox_games.pkl","rb")
    all_xbox_games = pickle.load(out)
    is_game_pass_game = lambda game: game["name"].lower() in game_pass_games_names
    found_games = [game for game in all_xbox_games if is_game_pass_game(game)]
    return found_games 

metrics = ['name', 'playtime', 'released', 'rating', 'rating_top', 'ratings_count', 'suggestions_count', 'reviews_text_count', 'added', 'reviews_count', 'esrb_rating']

def genre_rules(game):
    game_slug = game['slug']
    genre_slugs = [genre['slug'] for genre in game['genres']]
    return [f"genre({game_slug},{genre_slug})" for genre_slug in genre_slugs]

def rating_rules(game):
    game_slug = game['slug']
    ratings = [(rating['title'], rating['count']) for rating in game['ratings']]
    return [f"ratings({game_slug},{title},{count})" for (title, count) in ratings]

def get_metric_value(game, metric):
    if metric in ['name', 'released']:
        return "\"" + game[metric] + "\""
    elif metric == 'esrb_rating':
        return game[metric]['slug'] if game[metric] else None
    return game[metric]

def generate_rules_for_game(game):
    rules = []
    game_slug = game['slug']
    for metric in metrics:
        metric_value = get_metric_value(game, metric)
        if metric_value: rules.append(f"{metric}({game_slug},{metric_value})")
    rules += genre_rules(game)
    rules += rating_rules(game)
    return rules

def generate_rules(games):
    rules = []
    for game in games:
        rules += generate_rules_for_game(game)
    # Sort rules - rules of the same type should be grouped together.
    rules = sorted(rules)
    return ".\n".join(rules) + "."

games = get_games_from_file()
rules = generate_rules(games)
with open("games.pl", "w") as text_file:
    text_file.write(rules)