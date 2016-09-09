import * as Immutable from 'immutable'
import React from 'react'
import ReactDOM from 'react-dom'
import {connect} from 'react-redux';
import {
    Button,
    Panel,
    FormGroup,
    FormControl,
    Modal,
    ControlLabel,
    HelpBlock
} from 'react-bootstrap/dist/react-bootstrap.min.js'
import {v4} from 'node-uuid'
import * as Actions from '../actions/actions'


const User = ({user}) => {
    return (
        <li> {user} </li>
    )
}


const mapStateToProps = ({username, userlist, messages, ws}) => ({
    username,
    userlist,
    messages,
    ws
});

const mapDispatchToProps = (dispatch) => ({
    dispatch
});


@connect(mapStateToProps, mapDispatchToProps)
export default class Chat extends React.Component {
    constructor(props, context) {
        super(props, context)
        this.state        = {
            text: this.props.text || '',

        }
        this.shouldScroll = true
    }

    doUpdate() {
        let iv = setInterval(() => {
            /* console.log('interval');*/
            if (this.props.ws) {
                clearInterval(iv);
                this.props.dispatch(Actions.update());
            }
        }, 100)
    }

//    componentDidMount() {
    /* console.log('DID MOUNT', this.props.userlist);*/
    //this.doUpdate();
//    this.props.userlist.forEach( user => console.log(user) )
//    }

    /* componentWillReceiveProps( nextProps ) {
     *   console.log("nextProps: ", nextProps);
     * }*/


    handleSubmit(e) {
        const text = e.target.value.trim()
        if (e.which === 13 && !e.shiftKey) {
            e.preventDefault()
            this.props.dispatch(Actions.send_broadcast(text))
            this.setState({text: ''})
        }
    }

    handleChange(e) {
        this.setState({text: e.target.value})
    }

    getValidationState() {
        const length = this.state.text.length;
        if (length > 10) return 'success';
        else if (length > 5) return 'warning';
        else if (length > 0) return 'error';
    }

    logout() {
        this.props.dispatch(Actions.logout())
    }

    componentDidUpdate(prevProps, prevState) {
        if (this.shouldScroll) {
            this.refs.main.scrollTop = this.refs.main.scrollHeight
        }
    }

    componentWillUpdate() {
        let main          = this.refs.main
        this.shouldScroll = main.scrollTop + main.clientHeight === main.scrollHeight
    }

    messages(props) {
        let result        = []
        let last_username = ''
        props.messages.forEach(broadcast => {
            if (last_username !== broadcast.sender) {
                result.push(
                    <div className="user-row">
                        <div className="time"> {new Date(broadcast.timestamp).toLocaleTimeString()} </div>
                        <div className="username"> {broadcast.sender} </div>
                    </div>
                )
            }
            result.push(
                <div className="message-row">
                    <div className="cont-time"> {new Date(broadcast.timestamp).toLocaleTimeString()} </div>
                    <div className="message"> {broadcast.message} </div>
                </div>
            )
            last_username = broadcast.sender
        })
        return result
    }

    //show_time_username(props) {
    //    return (
    //        <div>
    //            <div className="time"> {new Date(broadcast.timestamp).toLocaleTimeString()} </div>
    //            <div className="username"> {broadcast.sender} </div>
    //        </div>
    //    )
    //}
    //
    //show_time_message(props) {
    //    return (
    //        <div key={broadcast.uuid}>
    //            <div className="cont-time"> {new Date(broadcast.timestamp).toLocaleTimeString()} </div>
    //            <div className="message"> {broadcast.message} </div>
    //        </div>
    //    )
    //}

    show_messages(props) {
        let last_username = ''
        let first_row     = true
        let result        = []

        for (let i of this.messages(props)) {
            result.push(i)
        }
    }

    render() {
        const props    = this.props
        const userlist = props.userlist

        return (
            <div className="container">
                <div className="header">
                    <div className="col-sm-12">
                        <Button className="pull-right" onClick={this.logout.bind(this)}> Выйти </Button>
                    </div>
                </div>
                <div className="">
                    <div className="main" ref="main">
                        {this.messages(props)}
                    </div>
                    <div className="sidebar">
                        <Panel>
                            <ul>
                                {userlist.map(user =>
                                    <User key={user} user={user}/>
                                )}
                            </ul>
                        </Panel>
                    </div>
                </div>
                <div className="footer">
                    <div className="col-sm-12">
                        <FormGroup
                            controlId="formBasicText"
                            validationState={this.getValidationState()}>
                            <FormControl
                                componentClass="textarea"
                                className="textarea"
                                type="text"
                                value={this.state.text}
                                placeholder="Напишите сообщение..."
                                onChange={this.handleChange.bind(this)}
                                onKeyDown={this.handleSubmit.bind(this)}/>
                        </FormGroup>
                    </div>
                </div>
            </div>
        )
    }
}

