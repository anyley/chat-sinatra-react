'use strict';

import React from 'react'
import { connect } from 'react-redux'

import * as Actions from '../actions/actions'
import Login from './Login.jsx'

const mapStateToProps = ({username, userlist, messages}) => ({
  username,
  userlist,
  messages
});

const mapDispatchToProps = (dispatch) => ({
  dispatch
});


@connect(mapStateToProps, mapDispatchToProps)
export default class App extends React.Component {
  constructor(props, context) {
    super(props, context)
    this.state = {
      text: this.props.text || ''
    }
//    console.log(this.props);
  }

  componentDidMount() {
    /* console.log('did mount !');
     * console.log(Actions.connect());*/
    let result = this.props.dispatch(Actions.connect());
    console.log("RESULT: ", result);
    /* .result((a) => {
       console.log("THEN: ", a);
       });*/
  }
  

  handleSubmit(e) {
    const text = e.target.value.trim()
    if (e.which === 13) {
      console.log('<ENTER>');
      this.setState({ text: '' });
      /* this.props.onSave(text)
       * if (this.props.newTodo) {
       *   this.setState({ text: '' })
       * }*/
    }
  }

  handleChange(e) {
    this.setState({ text: e.target.value })
  }
  
  render() {
    const props = this.props;
    /* console.log(this.props);
     */
    if (props.username != 'root') {
      return (
        <Login></Login>
      )
    }
    
    return (
      <div>
        <h1> { props.username } </h1>
        <div>
        <ul>
          {props.userlist.map( user =>
            <li key={user.id}> {user.name} </li>
          )}
        </ul>
        </div>
        <div>
          {props.messages.map( message =>
            <div className="message" key={message.id}>
              <span> {new Date(message.timestamp).toLocaleTimeString()} </span>
              <span> {message.sender}: </span>
              <span> {message.text} </span>
            </div>
          )}
        </div>
        <div>
          <input
            type="text"
            placeholder="Напишите сообщение..."
            autoFocus="true"
            value={this.state.text}
            onChange={this.handleChange.bind(this)}
            onKeyDown={this.handleSubmit.bind(this)} />
        </div>
      </div>
    )
  }

}

