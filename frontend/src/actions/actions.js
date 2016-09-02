'use strict';




export const connect = () => ({
  source: 'client',
  type: 'connect',
  ws_url: 'ws://localhost:5000/'
});

const receive = (message) => ({
  type: 'RECEIVE', message
})
