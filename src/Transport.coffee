_ = require 'underscore'
Backbone = require 'Backbone'
uuid = require 'uuid/v4'


class Transport
    constructor: (@config)->
        _.extend @, Backbone.Events
        @connect()

    url: (config)->
        return config.url

    connect: ->
        @trigger 'network', 'connecting'
        @_ws = new WebSocket @url @config
        @_bindWs()

    _bindWs: ->
        @_ws.onopen = =>
            @trigger 'network', 'connected'
            @_ws.onmessage = _.bind @onMessage, @

            if @config.updateTime
                @update()
                @_updater()

        @_ws.onerror = =>
            @trigger 'network', 'error'
            @_reconnect()

        @_ws.onclose = =>
            @trigger 'network', 'disconnected'
            @_reconnect()

    _updater: ->
        clearTimeout @_updaterTO if @_updaterTO?
        @_updaterTO = setTimeout =>
            @update()
            @_updater()
        , @config.updateTime

    _reconnect: ->
        clearTimeout @_reconnectTO

        @_reconnectTO = setTimeout =>
            @connect()
        , 5000

    update: ->
        if @_ws.readyState is 1
            @send @config.socketData

    send: (request)->
        id = uuid()
        @_ws.send JSON.stringify _.extend {id, request}

    onMessage: ({data})->
        try
            data = JSON.parse data

        catch e
            return @trigger 'message:parse_error', data

        if data.error?
            return @trigger 'message:error'. data.error

        return @trigger 'message:received', data.result


module.exports = Transport
