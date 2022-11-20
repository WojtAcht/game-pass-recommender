// class ButtonsSet { 

//     render() => {
//         return {
//           <div className="my-button">
//             <Button type="button" value="1" variant="success" onClick={() => Rate(gameIndex, 1)} > Like </Button>{' '}
//             <Button type="button" value="0" variant="dark" onClick={() => Rate(gameIndex, 0)} > Neutral </Button>{' '}
//             <Button type="button" value="-1" variant="danger" onClick={() => Rate(gameIndex, -1)} > Dislike </Button>{' '}
//           </div>
//         }
//     }
// }

import Button from 'react-bootstrap/Button';
import React, { useState } from "react";


export const ButtonsSet = (props) => {
    const [active_yes, setActiveYes] = useState(false); 
    const [active_neutral, setActiveNeutral] = useState(false); 
    const [active_no, setActiveNo] = useState(false); 

    const YesCallback = () => {
        setActiveYes(!active_yes);
        props.callback(props.gameIndex, 1);
    }
    const NeutralCallback = () => {
        setActiveNeutral(!active_neutral);
        props.callback(props.gameIndex, 0);
    }
    const NoCallback = () => {
        setActiveNo(!active_no);
        props.callback(props.gameIndex, -1);
    }
    
    return (
      <div className="my-button">
        <Button type="button" value="1" disabled={active_yes || active_neutral || active_no} variant={ active_yes ? "success" : "outline-success" } onClick={() => YesCallback()} > Like </Button>{' '}
        <Button type="button" value="0" disabled={active_yes || active_neutral || active_no} variant={ active_neutral ? "dark" : "outline-dark" } onClick={() => NeutralCallback()} > Neutral </Button>{' '}
        <Button type="button" value="-1" disabled={active_yes || active_neutral || active_no} variant={ active_no ? "danger" : "outline-danger" } onClick={() => NoCallback()} > Dislike </Button>{' '}
      </div>
    );
};

export default ButtonsSet;