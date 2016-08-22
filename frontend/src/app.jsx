import React from 'react'
import ReactDOM from 'react-dom'
import { createStore, combineReducers } from 'redux'
import { Provider } from 'react-redux'
import { Router, Route, browserHistory } from 'react-router'
import { syncHistoryWithStore, routerReducer } from 'react-router-redux'
import routes from './routes'

import * as reducers from './reducers'
//reducers.routing = routerReducer;



// store
const store = createStore(
    combineReducers({
        ...reducers,
        routing: routerReducer
    })
);
const history = syncHistoryWithStore(browserHistory, store);


// app renderer
const run = () => {
    ReactDOM.render(
        <Provider store={store}>
            <Router history={history} routes={routes} />
        </Provider>,
        document.getElementById('root')
    );
}


// subscribe to store events
store.subscribe(run);


// first state render
run();
