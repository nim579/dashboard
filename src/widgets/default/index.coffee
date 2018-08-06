_ = require 'underscore'
Backbone = require 'Backbone'
MainView = require '../../views/Main'


class Model extends Backbone.Model
    initialize: ->
        @view = new View model: @


class View extends MainView
    template: require('./template')
    el: null

    initialize: ->
        super
        @listenTo @model, 'change', @render

    prepareData: ->
        return @model.toJSON()


module.exports = {Model, View}
