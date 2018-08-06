_ = require 'underscore'
Backbone = require 'Backbone'
Widgets = require './widgets'
CollectionView = require './views/Collection'


class Default extends Backbone.Collection
    initialize: (models, @config)->
        # Extending widgets by user defined
        _.extend Widgets, @config.widgets unless _.isEmpty @config.widgets

        @view = new CollectionView collection: @

    _prepareModel: (attrs, options)->
        if @_isModel attrs
            attrs.collection = @ unless attrs.collection
            return attrs

        options = if options then _.clone(options) else {}
        options.collection = @

        modelClass = @_selectModel attrs
        model = new modelClass attrs, options
        return model unless model.validationError

        @trigger 'invalid', @, model.validationError, options
        return false

    _selectModel: ({name})->
        name = 'default' unless name
        name = 'default' unless Widgets[name]

        console.log name

        return Widgets[name]

    fetch: (data, options)->
        @set data, _.extend {add: false, merge: true, remove: false, sort: false}, options


class Auto extends Default
    fetch: (data, options)->
        @set data, _.extend {add: true, merge: true, remove: true, sort: true}, options


module.exports = {Default, Auto}
