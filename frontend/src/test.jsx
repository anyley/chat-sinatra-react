import React from 'react'
import ReactDOM from 'react-dom'
import { createStore } from 'redux'


// reducer
const counter = (state={}, action) => {
    switch(action.type) {
        case 'action_1':
            return {...state, ***};
            break;
        case 'action_2':
            return {...state, ***};
            break;
            
        case: 'TIMER':
            return {...state, time: new Date().toLocaleTimeString()};
            break;

        default:
            return state;
    }
}


// store
const store = createStore(/* TODO: добавить редюсеры и персистент стор */);


// component
class App extends React.Component {
    render() {
        return (
            <div>
            </div>
        )
    }
}


// app renderer
const run = () => {
    ReactDOM.render(
        <App
            counter={store.getState().***}
            onInc={() => store.dispatch({type: 'action_1'})}
            onDec={() => store.dispatch({type: 'action_2'})}
        />,
        document.getElementById('root')
    );
}


// subscribe to store events
store.subscribe(run);


// first state render
run();

setInterval( () => {
    store.dispatch({type: 'TIMER'})
}, 1000);

