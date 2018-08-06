MainView = require('./Main')


class SystemView extends MainView
    template: require('../templates/widgets')
    el: null

    initialize: ->
        super
        @listenTo @collection, 'add remove reset sort', @render

    prepareData: ->
        return widgets: @collection.map (model)-> model.id

    _getView: (name, id)->
        if name is 'widget'
            return @collection.get(id)?.view or null


module.exports = SystemView
