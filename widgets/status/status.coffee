class Dashboard.widgets.status extends Dashboard.widgets.standart
    defaults: ->
        return {
            value: 0
        }

    initialize: ->
        @view = new Dashboard.widgets.statusView model: @, id: @id

class Dashboard.widgets.statusView extends Dashboard.widgets.standartView
    className: 'widget status'

    getData: ->
        data = @model.toJSON()

        if data.value?.status
            data.status = data.value.status 
            data.value = data.value.text

        else
            data.value = data.value.text or undefined

        return data

