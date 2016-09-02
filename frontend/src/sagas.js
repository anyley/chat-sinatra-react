import { takeEvery } from 'redux-saga'
import { call, put, take, fork, receive, delay } from 'redux-saga/effects'
import * as Actions from './actions/actions'


function* createWebSocket(url) {
  
  const ws = new WebSocket(url)
  yield put({type: 'connected', ws: ws})
  let deferred
  
  ws.onmessage = event => {
    if(deferred) {
      deferred.resolve(JSON.parse(event.data))
      deferred = null 
    }
  }

  return {
    nextMessage() {
      if(!deferred) {
        deferred = {}
        deferred.promise = 
          new Promise(resolve => deferred.resolve = resolve)
      }
      return deferred.promise
    }
  }
}


function* watchMessages(ws) {
  console.log('begin receive messages')
  let msg = yield call(ws.nextMessage)
  while(msg) {
    yield put(receive(msg))
    msg = yield call(ws.nextMessage)
  }
  console.log('done receive messages') 
}


function* getMessagesOnLoad() {
  const { ws_url } = yield take('connect')
  yield delay(1)
  console.log("url: ", ws_url );
  const ws = yield call(createWebSocket, ws_url)
  yield fork(watchMessages, ws)
}


export default function* rootSaga() {
  yield [
    getMessagesOnLoad()
  ]
}
