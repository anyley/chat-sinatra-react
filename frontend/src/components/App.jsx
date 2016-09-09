'use strict';

import React from 'react'
import { connect } from 'react-redux'

import * as Actions from '../actions/actions'
import Login from './Login.jsx'
import Chat from './Chat.jsx'


const mapStateToProps = ({auth}) => ({
  auth
});

const mapDispatchToProps = (dispatch) => ({
  dispatch
});


@connect(mapStateToProps, mapDispatchToProps)
export default class App extends React.Component {
  
  componentDidMount() {
//   this.props.dispatch(Actions.connect());
  }
  
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

