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

или режима watch-тестирования

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
    
Далее в браузере заходим по адресу http://localhost:5000/
В development режиме будет сделан редирект на http://localhost:8080/
Это сделано для горячей замены кода (hot modules replacement) в React
