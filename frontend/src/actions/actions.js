'use strict';


export const connect = () => ({
  source: 'client',
  type: 'connect',
  ws_url: `ws://${location.hostname}:5000/`
});

export const connected = (ws) => ({
  type: 'connected',
  ws
})

export const disconnected = () => ({
  type: 'disconnected'
})

export const hello = () => ({
  source: 'server',
  type: 'hello'
});

export const update = () => ({
  source: 'client',
  type: 'update'
});

export const login = (username) => ({
  source: 'client',
  type: 'login',
  params: {
    username
  }
});

export const logout = () => ({
  source: 'client',
  type: 'logout'
});

export const send_broadcast = (message) => ({
  source: 'client',
  type: 'send_broadcast',
  params: {
    message
  }
});


export const send_private = (recipient, message) => ({
  source: 'client',
  type: 'private',
  params: {
    recipient,
    message
  }
});


