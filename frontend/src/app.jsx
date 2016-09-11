import 'babel-polyfill'

import 'bootstrap/dist/css/bootstrap.css'
import './assets/css/styles.css'

import React from 'react'
import ReactDOM from 'react-dom'
import { createStore, combineReducers, applyMiddleware } from 'redux'
import { Provider } from 'react-redux'
import { Router, Route, browserHistory } from 'react-router'
import { syncHistoryWithStore, routerReducer } from 'react-router-redux'

import createSagaMiddleware from 'redux-saga'
import rootSaga from './sagas'

import routes from './routes'
import * as reducers from './reducers'
import { loadState, saveState } from './localStore.js'


const sagaMiddleware = createSagaMiddleware()


/**
 * Logs all actions and states after they are dispatched.
 */
const logger = store => next => action => {
  console.group(action.type)
  console.log('action:', action)
  let result = next(action)
//  console.log('next state:', store.getState())
  console.groupEnd(action.type)
  return result
}


const persistedState = loadState();

// store
const store = createStore(
  combineReducers({
    ...reducers,
    routing: routerReducer
  }),
  persistedState,
  applyMiddleware(logger, sagaMiddleware)
);

sagaMiddleware.run(rootSaga)



store.subscribe( () => {
  const currentState = store.getState()
  saveState( {
//    auth: currentState.auth,
    username: currentState.username,
//    userlist: currentState.userlist,
//    messages: currentState.messages
  })
})


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
