_ = require 'underscore'
Backbone = require 'Backbone'
SystemView = require('./views/System')


class System extends Backbone.Model
    defaults: ->
        status: null

    initialize: ->
        @view = new SystemView model: @

        @on 'change:version', @onChangeVersion

    onChangeVersion: ->
        prevVersion = @previousAttributes().version
        version = @get('version')

        if version and prevVersion and version isnt prevVersion
            window.location.reload()


module.exports = System
