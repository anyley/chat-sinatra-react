import { takeEvery } from 'redux-saga'
import { call, put } from 'redux-saga/effects'


export function* helloSaga() {
  console.log('Hello Sagas!')
}

export default function* rootSaga() {
  yield [
    helloSaga()
  ]
}
