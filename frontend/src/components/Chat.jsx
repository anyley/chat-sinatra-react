import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux';

//import { Button } from 'react-bootstrap/dist/react-bootstrap.min.js'



// component
//class Login extends React.Component {
//    render() {
//        return (
//            <div>
//                <form ref="form"
//                      name="login"
//                      action="http://localhost:5000/login"
//                      className='form'
//                      method='post'>
//                    <label> Name: </label>
//                    <input type="text" name="username"/>
//                    <button type='submit'>Login</button>
//                </form>
//            </div>
//        )
//    }
//}
//
//
//
//export default connect()(Login);

const mapStateToProps = (state, props) => ({

});


const Login = ({}) => {
    return (
        <div>
            <h1> Login </h1>
        </div>)
};

export default connect(mapStateToProps)(Login);
