$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'Backbone'
moment = require 'moment'
Utils = require '../Utils'


class MainView extends Backbone.View
    template: require('../templates/main')
    el: 'body'

    initialize: ->
        super
        @render()

    render: ->
        @trigger 'beforeRender', @

        @$el.html @template _.extend @globalVars(), @prepareData()
        @attachPartials()

        @trigger 'render', @
        return @

    prepareData: -> {}

    globalVars: ->
        $: $
        _: _
        moment: moment
        Utils: Utils

    attachPartials: ->
        @partials = []

        @$('[data-partial]').each (i, el)=>
            name = $(el).data('partial')
            id   = $(el).data('partialId')
            view = null

            view = @_getView name, id

            return unless view
            view.setElement el
            view.render()

            @partials.push view

            @listenTo view, 'destroy', =>
                @partials = _.without @partials, view

    _getView: (name, id)->
        view = null

        switch name
            when 'system'
                view = @model.system?.view

            when 'content'
                view = @model.widgets?.view

        return view

module.exports = MainView
