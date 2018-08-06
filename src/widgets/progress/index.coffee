_ = require 'underscore'
DefaultWidget = require('../default')
Utils = require('../../Utils')


class Model extends DefaultWidget.Model
    initialize: ->
        @view = new View model: @


class View extends DefaultWidget.View
    template: require('./template')

    initialize: ->
        super
        @on 'render', @prevAnimate

    prepareData: ->
        data = super
        data._prev_value = @_prevValue or 0

        return data

    prevAnimate: ->
        $el = @$('.js_value')
        value = $el.data 'value'
        @_prevValue = value

        _.delay ->
            $el.css width: value
        , 1


module.exports = {Model, View}
