WebSocketServer = require('ws').Server

wss = new WebSocketServer port: 8888


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

con = 0
tcon = 0
sendMess = (ws)->
    data =
        tag: 'asd'
        result: 
            widgets: [
                name: 'table', dataId: 'store', label: 'seta', value: [
                    {"label": "set1_long_string_to_test", "value": 100},
                    {"label": "set2", "value": 100500}
                ]
            ,
                name: 'piechart', dataId: 'pie', firstAll: false, value: [
                    {"label": "set1", "value": 100},
                    {"label": "set2", "value": 1005},
                    {"label": "set3", "value": 505},
                ]
            ,
                name: 'clock', dataId: 'sup', value: wrap: false, exp: 'HH:MM.SS', utc: 4
            ]

    if tcon >= 3
        tcon = 0
        data.result.widgets[1].value[0].value = 800
        data.result.widgets[1].value[1].value = 500

    else
        data.result.widgets[1].value[0].value = 100
        data.result.widgets[1].value[1].value = 1005
        tcon++

    ws.send JSON.stringify data
        

