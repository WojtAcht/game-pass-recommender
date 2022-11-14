import './App.css';
import React, { useEffect, useState } from "react";
import Button from 'react-bootstrap/Button';

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
        {games.map((game, gameIndex) => {
          return (
            <div className="post-card" key={game.id}>
              <h2 className="post-title">{game.name}</h2>
              <img src={game.image} className="App-logo" alt="logo" />
              <div className="button">
                <Button as="input" type="button" value="+1" onClick={() => Rate(gameIndex, 1)} />{' '}
                <Button as="input" type="button" value="0" onClick={() => Rate(gameIndex, 0)} />{' '}
                <Button as="input" type="button" value="-1" onClick={() => Rate(gameIndex, -1)} />
              </div>
            </div>
          );
        })}
        <Button as="input" type="button" value="Submit" onClick={() => getRecommendations()} />{' '}
        {recommendations.map((game) => {
          return (
            <div className="post-card" key={game.id}>
              <h2 className="post-title">{game.name}</h2>
              <img src={game.image} className="App-logo" alt="logo" />
            </div>);
        })}
      </div>
    </div>
  );
}

export default App;
