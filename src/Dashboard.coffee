# Main dashboard class
window.Dashboard = {} unless Dashboard?

class Dashboard
    constructor: (config)->
        if config.widgets
            @widgetCollection = new Dashboard.Widgets [], config

            for widgetConfig in config.widgets
                name = if Dashboard.widgets[widgetConfig.name]? then widgetConfig.name else 'standart'
                widget = new Dashboard.widgets[name] _.extend {_dataId: widgetConfig.dataId, id: widgetConfig.dataId}, widgetConfig.extra

                @widgetCollection.add widget

        else
            console.log 'WidgetsServerConfig'
            @widgetCollection = new Dashboard.WidgetsServerConfig [], config


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


Dashboard.WidgetsServerConfig = Dashboard.Widgets.extend
    prepareData: (data)->
        if data.widgets
            updates = []
            for widget in data.widgets
                if @get(widget.dataId)
                    widget.id = widget.dataId
                    updates.push widget

                else
                    name = if Dashboard.widgets[widget.name]? then widget.name else 'standart'
                    widget.id = widget.dataId
                    widgetModel = new Dashboard.widgets[name] _.extend widget, last_update: new Date()
                    widgetModel.on 'change:value', ->
                        @set last_update: new Date()

                    updates.push widgetModel

            removedWidgets = @reject (model)->
                return _.find data.widgets, (widget)->
                    return model.id is widget.dataId

            @remove removedWidgets
            @set updates

    updated: (model)->
        model.set last_update: new Date()


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

    animateValue: (oldValue, value, renderFn)->
        if not value? or isNaN value
            return false

        timeout = 700
        delay = 20
        iterations = timeout / delay
        
        difference =  value - oldValue
        trendUp = oldValue < value
        step = Math.ceil difference/50

        to = setInterval ->
            oldValue += step
            if (trendUp and oldValue >= value) or (not trendUp and oldValue <= value)
                oldValue = value
                clearInterval to
                to = null

            renderFn? oldValue
        , delay

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

    _bindWs: ->
        @_ws.onopen = =>
            @_ws.onmessage = (message)=>
                @set @parse message.data

            if @config.updateTime
                @update()
                @_updater()

        @_ws.onerror = =>
            @_reconnect()

        @_ws.onclose = =>
            @_reconnect()

    _updater: ->
        clearTimeout @_updaterTO if @_updaterTO?
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

        if _.isArray data.result
            data = widgets: data.result

        return data.result


class Dashboard.View extends Backbone.View
    el: 'body'

    template: '<div class="container w-<%= grid.w %> h-<%= grid.h %>"></div>'
    widgetTemplate: '<div class="element"><div class="element-wrap"></div></div>'

    presets: [
        min: 1,  w: 1, h: 1
    ,
        min: 2,  w: 2, h: 1
    ,
        min: 3,  w: 2, h: 2
    ,
        min: 5,  w: 4, h: 2
    ,
        min: 9,  w: 3, h: 3
    ,
        min: 10, w: 4, h: 3
    ,
        min: 13, w: 5, h: 3
    ,
        min: 16, w: 4, h: 4
    ,
        min: 17, w: 5, h: 4
    ]

    initialize: ->
        @listenTo @collection, 'add remove', @render

    render: ->
        grid = _.first @presets
        for preset in @presets
            break if preset.min > @collection.length
            grid = preset

        $container = $(_.template(@template) grid: grid)

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
        @view = new Dashboard.widgets.standartView model: @, id: @id


Dashboard.widgets.standartView = Backbone.View.extend
    className: 'widget'
    template: '''
        <% if(typeof label != \'undefined\'){ %>
            <div class="title"><%= label %></div>
        <% } %>
        <span class="value">
            <% if(typeof value != \'undefined\'){ %>
                <%= value %>
            <% } %>
        </span>
        <% if(typeof last_update != \'undefined\'){ %>
            <div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div>
        <% } %>
    '''

    initialize: ->
        @listenTo @model, 'change', @render
        @render()

    getData: ->
        return @model.toJSON()

    render: ->
        data = @getData()
        @$el.html _.template(@template) data

        # XXX
        classes = @$el.attr 'class'
        statuses = _.filter classes.split(' '), (className)->
            return className.indexOf('mStatus_') > -1

        @$el.removeClass statuses.join ' '

        if data.status
            @$el.addClass 'mStatus_' + data.status


