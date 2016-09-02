'use strict';
import './localStore'
import * as Actions from './actions/actions'

/* {
 *   username: 'user-1',
 *   
 *   userlist: [
 *     {
 *       id: 1,
 *       name: 'user-1'
 *     },
 *     {
 *       id: 2,
 *       name: 'user-2'
 *     }
 *   ],
 *   messages: [
 *     {
 *       id: '1'
 *       type: 1 // broadcast (1) | private (2)
 *       status: 3 // 1 - отправлено на сервер, 2 - отправлено клиенту, 3 - прочитано
 *       timestamp: 123123123123
 *       sender: 'user-1'
 *       message: 'text'
 *     },
 *     ...
 *   ]
 * }
 
  {"username":"diver","userlist":[{"id":1,"name":"diver"},{"id":2,"name":"user-2"}],"messages":[{"id":1,"type":1,"status":1,"timestamp":1472532070835,"sender":"user-1","text":"text message!"},{"id":2,"type":2,"status":2,"timestamp":1472532070835,"sender":"user-2","text":"hi all..."},{"id":3,"type":1,"status":3,"timestamp":1472532070835,"sender":"user-3","text":"and ypu!"}]}}}

 * */

const handle = (dispatch, action) => {
  if (action.source !== 'server') {
    console.log('BAD SOURCE!');
    return;
  }
  
  switch( action.type) {
    case 'hello':
      console.log('hello');
      dispatch(Actions.hello());
      break;
  }
  
}


export const ws = (state=null, action) => {
  if (action.type !== 'connected') return state;

  console.log('ws: ', state, action);
//  const _ws = new WebSocket(action.ws_url); //'ws://localhost:5000/');

  /* _ws.onmessage = (response) => {
   *   const data = JSON.parse(response.data);
   *   data.type = data.action;
   *   console.log(data);
   *   handle(data);
   * };
   */
  return action.ws;
}


export const username = (state="", action) => {
  return state;
}


export const userlist = (state=[], action) => {
    switch(action.type) {
        case 'action_1':
            return [...state, action.data];
 
        default:
            return state;
    }
}

export const messages = (state=[], action) => {
  switch(action.type) {
    case 'action_1':
      return [...state, action.data];

    default:
      return state;
  }
}

