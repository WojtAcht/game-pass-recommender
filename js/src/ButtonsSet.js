import Button from 'react-bootstrap/Button';
import React, { useState } from "react";


export const ButtonsSet = (props) => {
    const [active, setActive] = useState([false, false, false]); 

    const YesCallback = () => {
        setActive([!active[0], active[1], active[2]]);
        props.callback(props.gameIndex, 1);
    }
    const NeutralCallback = () => {
        setActive([active[0], !active[1], active[2]]);
        props.callback(props.gameIndex, 0);
    }
    const NoCallback = () => {
        setActive([active[0], active[1], !active[2]]);
        props.callback(props.gameIndex, -1);
    }
    
    return (
      <div className="my-button">
        <Button type="button" value="1" disabled={active[0] || active[1] || active[2]} variant={ active[0] ? "success" : "outline-success" } onClick={() => YesCallback()} > Like </Button>{' '}
        <Button type="button" value="0" disabled={active[0] || active[1] || active[2]} variant={ active[1] ? "dark" : "outline-dark" } onClick={() => NeutralCallback()} > Neutral </Button>{' '}
        <Button type="button" value="-1" disabled={active[0] || active[1] || active[2]} variant={ active[2] ? "danger" : "outline-danger" } onClick={() => NoCallback()} > Dislike </Button>{' '}
      </div>
    );
};

export default ButtonsSet;