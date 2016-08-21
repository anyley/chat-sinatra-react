'use strict';

import 'bootstrap/dist/css/bootstrap.css'
import './assets/css/styles.css'


console.log('hello!');

let ws = new WebSocket('ws://localhost:5000/');
ws.onmessage = (response) => {
    console.log(response.data);
    const data = JSON.parse(response.data);
    let root = document.getElementById('root');
    let div = document.createElement('div');
    div.innerHTML = data.text;
    root.appendChild(div);

};

const waitForWebSocket = (socket, callback) => setTimeout(() => {
    if (socket.readyState == 1) {
        callback();
    }
    else {
        console.log(socket);
        waitForWebSocket(socket, callback);
    }

}, 10);

waitForWebSocket(ws, () => {
    ws.send(JSON.stringify({command: 'ping', text: 'this url http://ya.ru and this url https://google.com the end'}));
});
