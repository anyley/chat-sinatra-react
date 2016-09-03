'use strict';

import React from 'react'
import { connect } from 'react-redux'
import { Button, FormGroup, FormControl, Modal } from 'react-bootstrap/dist/react-bootstrap.min.js'
import { throttle } from 'lodash'

import * as Actions from '../actions/actions'

const mapStateToProps = ({ws, connection_process, status, username}) => ({
  ws, connection_process, status, username
});


@connect(mapStateToProps)
export default class Login extends React.Component {
  constructor(props, context) {
    super(props, context)
    this.state = {
      text: this.props.text || '',
    }
    let iv = null
  }

  reconnect() {
    console.log('reconnect !!!');
    this.props.dispatch(Actions.connect())
  }

  componentWillUnmount() {
    clearInterval(this.iv)
  }

  componentDidMount() {
//    console.log(this.props.status);
    this.iv = setInterval(() => {
      console.log(this.iv, this.props.status, this.props.connection_process);
      if (!this.props.status && !this.props.connection_process)
        this.reconnect()
    }, 1000)
  }

  componentWillReceiveProps( nextProps ) {
//    if (!nextProps.status) throttle( this.reconnect(), 1500 )
  }

  handleSubmit(e) {
    const text = e.target.value.trim()
    if (e.which === 13) {
      this.props.dispatch(Actions.login(text))
      this.setState({ text: '' })
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

    return (
      <Modal.Dialog autoFocus="true">
        <Modal.Header>
          <Modal.Title> Вход в чат
            <span className="pull-right" dangerouslySetInnerHTML={{__html: (this.props.status ? '[<span style="color:green">ONLINE</span>]' : '[<span style="color:red">OFFLINE</span>]') }} />
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <FormGroup bsSize="large">
            <FormControl bsSize="large" type="text" placeholder="Введите имя..."
                         autoFocus="true"
                         value={this.state.text}
                         onChange={this.handleChange.bind(this)}
                         onKeyDown={this.handleSubmit.bind(this)} />
          </FormGroup>
          <Button bsStyle="primary" bsSize="large" block> Войти </Button>
        </Modal.Body>
      </Modal.Dialog>
    )
  }
}
