'use strict';

import React from 'react'
import { connect } from 'react-redux'


const mapStateToProps = (state, props) => ({

});




@connect(mapStateToProps)
export default class App extends React.Component {
    render() {
        return (
            <div>
                <h1> Hello !</h1>
            </div>
        )
    }

};

//export default connect(mapStateToProps)(App);
