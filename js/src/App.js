import './App.css';
import React, { useEffect, useState } from "react";
import Button from 'react-bootstrap/Button';
import 'bootstrap/dist/css/bootstrap.min.css';
import ButtonsSet from './ButtonsSet';

function App() {
  const [games, setGames] = useState([]);
  const [ratings, setRatings] = useState([0, 0, 0, 0, 0]);
  const [recommendations, setRecommendations] = useState([]);

  const Rate = (gameIndex, value) => {
    const newRatings = ratings;
    newRatings[gameIndex] = value;
    console.log(value);
    setRatings(newRatings);
  }

  const getRecommendations = () => {
    const ids = games.map((game) => game.id);
    const requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ games: ids, ratings: ratings })
    };
    fetch('http://localhost:3000/api/v1/games/recommend', requestOptions)
      .then(response => response.json())
      .then(data => setRecommendations(data.games));
  }

  useEffect(() => {
    fetch('http://localhost:3000/api/v1/games')
      .then((res) => res.json())
      .then((data) => {
        setGames(data.games);
      })
      .catch((err) => {
        console.log(err.message);
      });
  }, []);

  

  return (
    <div className="App">
      <div className="posts-container">
        <div className="ask-games">
        {games.map((game, gameIndex) => {
          return (
            <div className="post-card" key={game.id}>
              <h2 className="post-title">{game.name}</h2>
              <img src={game.image} className="App-logo" alt="logo" />
              <ButtonsSet gameIndex={gameIndex} callback={Rate} />
            </div>
          );
        })}&nbsp;
        </div>
        <div className="recommend-games">
          <Button as="input" type="button" value="Submit" onClick={() => getRecommendations()} />{' '}
        </div>&nbsp;
        <div className="recommended-games">
        {recommendations.map((game) => {
          return (
            <div className="post-card" key={game.id}>
              <h2 className="post-title">{game.name}</h2>
              <img src={game.image} className="App-logo" alt="logo" />
            </div>);
        })}
        </div>
      </div>
    </div>
  );
}

export default App;
