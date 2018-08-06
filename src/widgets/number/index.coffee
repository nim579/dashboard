DefaultWidget = require('../default')
Utils = require('../../Utils')


class Model extends DefaultWidget.Model
    initialize: ->
        @view = new View model: @


class View extends DefaultWidget.View
    template: require('./template')


module.exports = {Model, View}
