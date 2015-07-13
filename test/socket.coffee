WebSocketServer = require('ws').Server
_ = require 'underscore'
fs = require 'fs'

wss = new WebSocketServer port: 8888

mdata = [
    {movie: 'Интерстеллар', status: 'success'},
    {movie: '300 спартанцев', status: 'success'},
    {movie: 'Мстители', status: 'success'},
    {movie: 'Гравитайия', status: 'success'},
    {movie: 'Бёрдмэн', status: 'success'},
    {movie: 'Снайпер', status: 'success'},
    {movie: 'Игра в иммитацию', status: 'success'},
    {movie: 'Отель Гранд Будапешт', status: 'success'},
    {movie: 'Левиафан', status: 'success'},
    {movie: 'Город героев', status: 'success'},
    {movie: 'Ярость', status: 'success'},
    {movie: 'Хоббит 1', status: 'success'},
    {movie: 'Большие глаза', status: 'success'},
    {movie: 'Люси', status: 'success'},
    {movie: 'Сирена', status: 'warning'},
    {movie: 'Дракула', status: 'success'},
    {movie: 'Отрочество', status: 'success'},
    {movie: 'Стражи галактики', status: 'success'},
    {movie: 'Бегущий в лабиринте', status: 'success'},
    {movie: 'Капитан Америка', status: 'success'},
    {movie: 'Капитан Филлипс', status: 'success'},
    {movie: 'Грань будущего', status: 'success'},
    {movie: 'Великий уравнитель', status: 'error'},
    {movie: 'Живая сталь', status: 'success'},
    {movie: 'Пряности и страсти', status: 'success'}
]
statuses = ['success', 'warning', 'error']


wss.on 'connection', (ws)->
    to = null
    console.log 'connected', wss.clients.length

    ws.on 'message', (mes)->
        console.log('received: %s', mes);
        # sendMess ws

    ws.on 'error', ->
        console.log 'error', arguments
        clearInterval to

    ws.on 'close', ->
        console.log 'disconnect', arguments
        clearInterval to

    to = setInterval ->
        sendMess ws
    , 3000

    sendMess ws

moviesCount = 5
# setInterval ->
#     moviesCount = _.random(1, 7)
# , 10000

con = 0
tcon = 0
sendMess = (ws)->
    movies = getMovies()
    stat = _.random 100000000
    movies.unshift name: 'meter', dataId: '__statistic__', value: stat, max: 100000000, label: 'test test'
    data =
        tag: 'asd'
        result: 
            widgets: movies
            version: JSON.parse(fs.readFileSync('./package.json').toString()).version

    ws.send JSON.stringify data

getMovies = ->
    return _.map mdata.slice(0, moviesCount), (movie)->
        return name: 'status', dataId: movie.movie, value: text: movie.movie, status: statuses[_.random(0, statuses.length - 1)]

generateStatistic = (movies)->
    statusGroups = _.groupBy movies, (movie)->
        return movie.value.status

    stat = []
    for status of statusGroups
        stat.push {label: status, value: statusGroups[status].length}

    return stat




