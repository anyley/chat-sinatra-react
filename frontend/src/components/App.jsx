'use strict';

import React from 'react'
import {connect} from 'react-redux'

import Login from './Login.jsx'
import Chat from './Chat.jsx'


const mapStateToProps = (state) => {
    console.log('mapStateToProps:', state)
    return ({
        auth: state.auth
    });
}

const mapDispatchToProps = (dispatch) => ({
    dispatch
});


@connect(mapStateToProps, mapDispatchToProps)
export default class App extends React.Component {
    render() {
        if (!this.props.auth) {
            return (
                <Login> {this.props.children} </Login>
            )
        } else {
            return (
                <Chat> {this.props.children} </Chat>
            )
        }
    }
}

