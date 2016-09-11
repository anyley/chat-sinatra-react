'use strict';

import React from 'react'
import {connect} from 'react-redux'
import {Button, FormGroup, FormControl, Modal} from 'react-bootstrap/dist/react-bootstrap.min.js'
import {throttle} from 'lodash'

import * as Actions from '../actions/actions'


// Показывает статус подключеиня в заголовке диалога
const Status = ({status}) => {
    const colors = {
        'disconnected': 'red',
        'connecting':   'blue',
        'connected':    'green'
    }

    return (
        <span className="pull-right" dangerouslySetInnerHTML={{
            __html: `[<span style="color:${colors[status]}"> ${status} </span>]`
        }}/>
    )
}


const mapStateToProps = ({ws, connection_status, username}) => ({
    ws, connection_status, username
})

const mapDispatchToProps = (dispatch) => ({
    dispatch
})


@connect(mapStateToProps, mapDispatchToProps)
export default class Login extends React.Component {
    constructor(props, context) {
        super(props, context)
        this.state = {
            text: this.props.text || '',
        }
        let iv = null, iv2 = null
    }

    reconnect() {
        this.props.dispatch(Actions.connect())
    }

    componentWillUnmount() {
        clearInterval(this.iv)
    }

    componentDidMount() {
        this.iv = setInterval(() => {
            if (this.props.connection_status == 'disconnected')
                this.reconnect()
        }, 250)
    }

    submit() {
        this.props.dispatch(Actions.login(this.state.text.trim()))
    }

    handleChange(e) {
        this.setState({text: e.target.value})
    }

    handleSubmit(e) {
        this.handleChange(e)
        if (e.which === 13) {
            this.submit()
        }
    }

    render() {
        const props = this.props;

        return (
            <Modal.Dialog autoFocus="true">
                <Modal.Header>
                    <Modal.Title>
                        Вход в чат
                        <Status status={props.connection_status}/>
                    </Modal.Title>
                </Modal.Header>

                <Modal.Body>
                    <FormGroup bsSize="large">
                        <FormControl bsSize="large" type="text" placeholder="Введите имя..."
                                     autoFocus="true"
                                     value={this.state.text}
                                     onChange={this.handleChange.bind(this)}
                                     onKeyDown={this.handleSubmit.bind(this)}/>
                    </FormGroup>
                    <Button bsStyle="primary" bsSize="large" block
                            onClick={this.submit.bind(this)}>
                        Войти
                    </Button>
                </Modal.Body>
            </Modal.Dialog>
        )
    }
}
