# Main dashboard class
window.Dashboard = {} unless Dashboard?

class Dashboard
    constructor: (config)->
        @widgetCollection = new Dashboard.Widgets [], config

        for widgetConfig in config.widgets
            name = if Dashboard.widgets[widgetConfig.name]? then widgetConfig.name else 'standart'
            widget = new Dashboard.widgets[name] _.extend {_dataId: widgetConfig.dataId}, widgetConfig.extra

            @widgetCollection.add widget


Dashboard.Widgets = Backbone.Collection.extend
    initialize: (models, @config)->
        @client = new Dashboard.Client @config
        @view = new Dashboard.View collection: @

        @listenTo @client, 'dataUpdated', (changed)->
            console.log 'changed', changed
            @prepareData changed

    prepareData: (data)->
        for dataSet of data
            model = @find (model)->
                return model.get('_dataId') is dataSet

            if model
                model.set value: data[dataSet], last_update: new Date()


Dashboard.widgets = {}

###
For future
Dashboard.templates = {}
###

Dashboard.utils =
    getGuid: ->
        s4 = ->
            return Math.floor((1 + Math.random()) * 0x10000)
                .toString(16)
                .substring(1)

        return "#{s4()}#{s4()}-#{s4()}-#{s4()}-#{s4()}-#{s4()}#{s4()}#{s4()}"

    shortenedNumber: (num)->
        if isNaN num
            return num

        newNum = num
        if num >= 1000000000
            newNum = (num / 1000000000).toFixed(1) + 'B'

        else if num >= 1000000
            newNum = (num / 1000000).toFixed(1) + 'M'

        else if num >= 1000
            newNum = (num / 1000).toFixed(1) + 'K'

        else
            newNum = num

        return newNum.toString().replace /\B(?=(\d{3})+(?!\d))/g, "&thinsp;"


class Dashboard.Client extends Backbone.Model
    initialize: (@config)->
        @connect()

        @on 'change', ->
            @trigger 'dataUpdated', @changed

    url: (config)->
        return config.url

    connect: ->
        @_ws = new WebSocket @url @config
        @_bindWs()
        @_updater()

    _bindWs: ->
        @_ws.onopen = =>
            @_ws.onmessage = (message)=>
                @set @parse message.data

            @update()

        @_ws.onerror = =>
            @_reconnect()

    _updater: ->
        @_updaterTO = setTimeout =>
            @update()
            @_updater()
        , @config.updateTime

    _reconnect: ->
        console.log 'Connection error'

        setTimeout =>
            @connect()
        , 2000

    update: ->
        udid = Dashboard.utils.getGuid()

        @_ws.send JSON.stringify _.extend {tag: udid}, @config.socketData

    parse: (data)->
        if typeof data is 'string'
            data = JSON.parse data

        return data.result


class Dashboard.View extends Backbone.View
    el: 'body'

    template: '<div class="container"></div>'
    widgetTemplate: '<div class="element w-3 h-2"><div class="element-wrap"></div></div>'

    initialize: ->
        @listenTo @collection, 'add', @render

    render: ->
        $container = $ @template

        for model in @collection.models
            if model.view
                $widget = $ @widgetTemplate
                $widget.find('.element-wrap').html model.view.$el
                $container.append $widget

        @$el.html $container


Dashboard.widgets.standart = Backbone.Model.extend
    defaults: ->
        return {
            value: 0
        }

    initialize: ->
        @view = new Dashboard.widgets.standartView model: @


Dashboard.widgets.standartView = Backbone.View.extend
    className: 'widget'
    template: '<div class="title"><%= label %></div><span class="value"><%= value %></span><% if(typeof last_update != \'undefined\'){ %><div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div><% } %>'

    initialize: ->
        @listenTo @model, 'change', @render
        @render()

    getData: ->
        return @model.toJSON()

    render: ->
        data = @getData()
        @$el.html _.template(@template) data

        classes = @$el.attr 'class'
        statuses = _.filter classes.split(' '), (className)->
            return className.indexOf('mStatus_') > -1

        @$el.removeClass statuses.join ' '

        if data.status
            @$el.addClass 'mStatus_' + data.status


