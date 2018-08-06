_ = require 'underscore'
Backbone = require 'Backbone'
Collections = require('./collection')
System = require('./System')
Transport = require('./Transport')
MainView = require('./views/Main')


class Dashboard
    constructor: (config)->
        _.extend @, Backbone.Events

        @transport = new Transport config
        @system = new System config

        if config.presets
            @widgets = new Collections.Default config.presets, config

        else
            @widgets = new Collections.Auto [], config

        @view = new MainView model: @

        @listenTo @transport, 'network', @networkStatus
        @listenTo @transport, 'message:received', @message

    networkStatus: (status)->
        @system.set {status}

    message: (data)->
        widgets = null
        version

        if _.isArray data
            widgets = data

        else
            widgets = data.widgets if data.widgets
            version = data.version if data.version

        @widgets.fetch widgets unless _.isEmpty widgets
        @system.set {version} if version


module.exports = Dashboard
