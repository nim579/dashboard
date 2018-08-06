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
    console.log 'connected', wss.clients.size

    ws.on 'message', (mes)->
        console.log('received: %s', mes);
        # sendMess ws

    ws.on 'error', ->
        console.log 'error', arguments

    ws.on 'close', ->
        console.log 'disconnect', arguments

    sendMess()

setInterval ->
    sendMess()
, 3000

widgetsCount = 1


prev = 0
# setInterval ->
#     moviesCount = _.random(1, 7)
# , 10000

con = 0
tcon = 0
sendMess = ->
    widgets = getMovies()
    stat = _.random 100000000

    widgets.unshift
        name: 'percentage'
        id: '__pw__'
        label: 'Percentage widget'
        divider: _.random 100
        dividend: _.random 100

    widgets.unshift
        name: 'progress'
        id: '__psw__'
        label: 'Progress widget'
        value: _.random 1200
        max: 1000

    widgets.unshift
        name: 'number'
        id: '__nw__'
        label: 'Number widget'
        value: stat
        previous: value: prev

    widgets.unshift
        name: 'clock'
        id: '__cw__'
        label: null
        format: null

    prev = stat
    # widgets.unshift name: 'meter', id: '__statistic__', label: 'test test', value: stat, max: 100000000

    widgets = widgets.slice 0, widgetsCount

    data =
        id: 'asd'
        error: null
        result:
            widgets: widgets
            version: JSON.parse(fs.readFileSync('./package.json').toString()).version

    wss.clients.forEach (ws)->
        ws.send JSON.stringify data

    widgetsCount++
    widgetsCount %= 19
    widgetsCount = 6

getMovies = ->
    return _.map mdata, (movie)->
        return name: 'status', id: movie.movie, value: movie.movie, status: statuses[_.random(0, statuses.length - 1)]

generateStatistic = (movies)->
    statusGroups = _.groupBy movies, (movie)->
        return movie.value.status

    stat = []
    for status of statusGroups
        stat.push {label: status, value: statusGroups[status].length}

    return stat
