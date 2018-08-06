MainView = require('./Main')


class SystemView extends MainView
    template: require('../templates/system')
    el: null

    initialize: ->
        super
        @listenTo @model, 'change:status', @render
        @listenTo @model, 'change:status', @onStatus

    prepareData: ->
        return @model.toJSON()

    onStatus: ->
        status = @model.get 'status'
        clearTimeout @_alertTO

        @$('.js_alert').addClass 'm_visible'

        if status is 'connected'
            @_alertTO = setTimeout =>
                @$('.js_alert').removeClass 'm_visible'
            , 2000


module.exports = SystemView
