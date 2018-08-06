DefaultWidget = require('../default')
Utils = require('../../Utils')


class Model extends DefaultWidget.Model
    initialize: ->
        @view = new View model: @


class View extends DefaultWidget.View
    template: require('./template')

    initialize: ->
        @on 'render', @setTO

    setTO: ->
        data = @prepareData()

        to = data.timeout or 1000
        go = => @render()

        clearTimeout @_TO
        @_TO = setTimeout go, to

    destroy: ->
        clearTimeout @_TO
        super


module.exports = {Model, View}
