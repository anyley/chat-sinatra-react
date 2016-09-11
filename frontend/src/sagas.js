import {takeEvery} from 'redux-saga'
import {call, put, take, fork, select, cancel} from 'redux-saga/effects'
import * as Actions from './actions/actions'

let ws = null

const getUsername = state => state.username


function* createWebSocket(url) {
    ws = new WebSocket(url)
    let deferred, open_deferred, close_deferred, error_deferred;

    ws.onopen = event => {
        if (open_deferred) {
            open_deferred.resolve(event)
            open_deferred = null
        }
    }

    ws.onmessage = event => {
        if (deferred) {
            deferred.resolve(JSON.parse(event.data))
            deferred = null
        }
    }

    ws.onerror = event => {
        if (error_deferred) {
            error_deferred.resolve(JSON.parse(event.data))
            error_deferred = null
        }
    }

    ws.onclose = event => {
        if (close_deferred) {
            close_deferred.resolve(event)
            close_deferred = null
        }
    }

    return {
        open:    {
            nextMessage() {
                if (!open_deferred) {
                    open_deferred         = {}
                    open_deferred.promise = new Promise(resolve => open_deferred.resolve = resolve)
                }
                return open_deferred.promise
            }
        },
        message: {
            nextMessage() {
                if (!deferred) {
                    deferred         = {}
                    deferred.promise = new Promise(resolve => deferred.resolve = resolve)
                }
                return deferred.promise
            }
        },
        error:   {
            nextMessage() {
                if (!error_deferred) {
                    error_deferred         = {}
                    error_deferred.promise = new Promise(resolve => error_deferred.resolve = resolve)
                }
                return error_deferred.promise
            }
        },
        close:   {
            nextMessage() {
                if (!close_deferred) {
                    close_deferred         = {}
                    close_deferred.promise = new Promise(resolve => close_deferred.resolve = resolve)
                }
                return close_deferred.promise
            }
        }
    }
}


function* watchOpen(ws) {
    let msg = yield call(ws.nextMessage)
    while (msg) {
        yield put(Actions.connected(msg.srcElement))
        msg = yield call(ws.nextMessage)
    }
}


function* watchClose(ws) {
    let msg = yield call(ws.nextMessage)
    yield put(Actions.disconnected())
    ws = null
}


function* watchErrors(ws) {
    let msg = yield call(ws.nextMessage)
    while (msg) {
        msg = yield call(ws.nextMessage)
    }
}


function* watchMessages(ws) {
    let msg = yield call(ws.nextMessage)
    while (msg) {
        yield put(msg)
        msg = yield call(ws.nextMessage)
    }
}


function* connect() {
    let openTask, msgTask, errTask, closeTask

    while (true) {
        const {ws_url} = yield take('connect')
        const ws       = yield call(createWebSocket, ws_url)

        if (openTask) {
            yield cancel(openTask)
            yield cancel(msgTask)
            yield cancel(errTask)
            yield cancel(closeTask)
        }

        openTask  = yield fork(watchOpen, ws.open)
        msgTask   = yield fork(watchMessages, ws.message)
        errTask   = yield fork(watchErrors, ws.error)
        closeTask = yield fork(watchClose, ws.close)
    }
}


const send = (data) => {
    try {
        ws.send(JSON.stringify(data))
    } catch (error) {
        alert("Send error: " + error)
    }
}

function* login() {
    while (true) {
        const login_action = yield take('login')
        send(login_action)
    }
}

function* hello() {
    while (true) {
        const hello_action = yield take('hello')
        const username     = yield select(getUsername)
        if (username) {
            send(Actions.login(username))
        }
    }
}


function* disconnected() {
    while (true) {
        yield take('disconnected')
    }
}


export default function* rootSaga() {
    yield [
        connect(),
        hello(),
        login(),
        disconnected()
    ]
}
