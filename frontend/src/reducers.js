'use strict';

import * as Immutable from 'immutable'
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

let socket;


export const connection_process = (state=false, action) => {
  if (action.type === 'connect') {
    return true
  }

  if (action.type === 'connected') {
    return false
  }    

  return state
}


export const status = (state=false, action) => {
  if (action.type === 'disconnected') {
    return false
  }

  if (action.type === 'connected') {
    return true
  }    

  return state
}


export const ws = (state=null, action) => {
  if (action.type === 'connected') {
    socket = action.ws;
    return action.ws
  }

  if (action.type === 'disconnected') {
    socket = null
    
    return null
  }

  return state
}

let user = '';

export const username = (state="", action) => {
  switch(action.type) {
    case 'login':
      user = action.params.username
      return state

    case 'welcome':
      return user
      
    case 'logout':
      if (socket)
        socket.send( JSON.stringify(action) )
      return ''

    default:
      return state
  }
}


export const userlist = (state = new Immutable.Set(), action) => {
  switch(action.type) {
    case 'add_user':
        return state.add(action.params.username)
      
    case 'del_user':
        return state.delete(action.params.username)
      
    case 'welcome':
        return new Immutable.Set(action.params.userlist)

    default:
      return state
  }
}

export const messages = (state=[], action) => {
  switch(action.type) {
    case 'send_broadcast':
      if (socket) {
        socket.send( JSON.stringify(action) )
      }
      return state

    case 'broadcast':
      return [...state, action.params]

    default:
      return state
  }
}

