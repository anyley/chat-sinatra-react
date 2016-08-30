#chat-sinatra-react
[![GitHub license](https://img.shields.io/badge/license-ISC-blue.svg)](https://raw.githubusercontent.com/anyley/chat-sinatra-react/master/LICENSE) [![Build Status](https://travis-ci.org/anyley/chat-sinatra-react.svg?branch=master)](https://travis-ci.org/anyley/chat-sinatra-react) [![Code Climate](https://codeclimate.com/github/anyley/chat-sinatra-react/badges/gpa.svg)](https://codeclimate.com/github/anyley/chat-sinatra-react) [![Test Coverage](https://codeclimate.com/github/anyley/chat-sinatra-react/badges/coverage.svg)](https://codeclimate.com/github/anyley/chat-sinatra-react/coverage)

###ТЗ: Разработать простой пример многопользовательского чата

* Рекомендуемый стек:
    - Бэкенд на Ruby, хранение в базе данных не требуется,
либо можно взять SQLite для простоты.
    - Фронтенд на любом удобном фреймворке *ReactJS*

* Первый экран — форма логина.
    - Вводим nickname, попадаем в мультиюзерский чат.
    - Если перезагрузить страницу, форма логина повторно вылазить не должна, пока сами не захотим разлогиниться.
    - Ссылки в сообщениях должны быть кликабельными.

* Все остальное — полностью на ваше усмотрение.
    - Мы специально сделали минимально ТЗ,
    чтобы вы максимально смогли проявить свою фантазию,
    как в плане выбора инструментов, так и в плане идей
    и умение правильно додумывать вещи.

---
###О программе
Программа состоит из двух основных частей:
- Backend, обрабатывающий запросы браузера по websocket
- Frontend, клиентское приложение, написанное с применением **React + Redux**,
выполняющееся в браузере

---
###Установка backend
Бэкэнд разработан на **Ruby 2.3.1** + **Sinatra**.
Для установки необходимо выполнить команду:

    bundle install

###Настройка backend
В файле **.env** указать адреса серверов, например:

    # порт backend-сервера
    PORT=5000
    
    # адрес Redis сервера (опциоанльно)
    REDIS_URL=redis://localhost:6379
    
    # адрес frontend-сервера (webpack-dev-server с HMR, например)
    REACT_URL=http://localhost:8080

###Тестирование backend
    
    bundle exec rspec

или для режима watch-тестирования

    bundle exec guard
    
---
###Установка клиента (frontend)
    
    npm install

###Сборка клиента
    
    npm run build
    
###Тестирование клиента
 
    npm run test
    
###Запуск приложения

    foreman start 
    
Далее в браузере заходим по адресу [http://localhost:5000/](http://localhost:5000/)
В development режиме будет сделан редирект на [http://localhost:8080/](http://localhost:8080/)
Это сделано для горячей замены кода (hot modules replacement) в React

После запуска backend-а к нему можно для тестирования API подключиться из консоли браузера:
```javascript
      ws = new WebSocket('ws://localhost:5000/');
      ws.onmessage = (response) => {
          console.log(response.data);
      };
```
Данная команда создаст websocket и будет отображать сообщения от сервера в консоле.
Протокол общения с сервером такой:

* Сразу после соединения по websocket, сервер отправит клиенту команду:
```json
{source: 'server', action: 'hello'}
```
* После :hello клиент должен отправить на сервер сообщение:
```json
    {source: 'client', action: 'login', username: 'USERNAME'}
```
* Если имя занято, сервер пришлет ошибку:
```json
    {"source":"server","action":"error","params":{"message":"Username already used"}}
```
* Если имя не занято, сервер пришлет сообщение:
```json
    {source: 'server', action: 'welcome', params: {userlist: [...]}}
```
* После успешного логина сервер делает рассылку всем о добавлении нового пользователя:
```json
    {"source":"server","action":"add_user","params":{"username":"USERNAME"}}
```
* Получить полный список пользователей с сервера можно командой:
```json
    {source: 'client', action: 'update'}
```
* На запрос об апдейте сервер снова пришлет welcome с полным списком пользователей
* Отправить сообщение всем можно командой:
```json
    {source: 'client', action: 'broadcast', params: {message: 'hi all'}}
```
* Отправить приватное сообщение:
```json
    {source: 'client', action: 'private', params: { recipient: 'USER_2', message: 'hello' } }
```
* После отправки приватного сообщения, отправителю и получителю будет направлен одинаковый пакет данных:
```json
    { source: 'server', action: 'private', params: { timestamp: 1472512730000, sender: "USER_1", recipient: "USER_2", message: "Hi USER_2", uuid: "774f9cd8-9c62-478e-bd47-2e817861bb7a" }
```
* Отключиться от чата можно либо закрыв браузер, либо командой:
```json
    {source: 'client', action: 'logout'}
```
* После отключения пользователя сервер оповестит всех клиентов сообщением:
```json
    {"source":"server","action":"del_user","params":{"username":"USERNAME"}}
```
Отправлять команды серверу из консоли браузера можно так:
```javascript
    ws.send(JSON.stringify({source: 'client', action: 'login', params: {username: 'Name'}}))
    ws.send(JSON.stringify({source: 'client', action: 'broadcast', params: {message: 'hi all'}}))
    ws.send(JSON.stringify({source: 'client', action: 'update' }))
    ws.send(JSON.stringify({source: 'client', action: 'logout' }))
```
