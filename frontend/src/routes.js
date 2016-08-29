'use strict';

import React from 'react'
import {Route} from 'react-router'
import App from './components/App.jsx'
import Login from './components/Login.jsx'

export default (
    <Route path="/" component={App}>
        <Route path="/login" component={Login} />
        <Route path="/chat" component={Chat} />
    </Route>
);
