'use strict';

import React from 'react'
import { connect } from 'react-redux'
import { Button, FormGroup, FormControl, Modal } from 'react-bootstrap/dist/react-bootstrap.min.js'

import '../actions/actions'

const mapStateToProps = ({username}) => ({
  username
});


@connect(mapStateToProps)
export default class Login extends React.Component {
  constructor(props, context) {
    super(props, context)
    this.state = {
      text: this.props.text || ''
    }
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

    return (
      <Modal.Dialog autoFocus="true">
        <Modal.Header>
          <Modal.Title> Вход в чат </Modal.Title>
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
