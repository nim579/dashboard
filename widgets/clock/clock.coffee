class Dashboard.widgets.clock extends Dashboard.widgets.standart
    defaults: ->
        return {
            mode: 'current'
        }

    initialize: ->
        @view = new Dashboard.widgets.clockView model: @, id: @id

class Dashboard.widgets.clockView extends Dashboard.widgets.standartView
    className: 'widget clock'

    render: ->
        super()

        data = @getData()
        data.mode = data.value.mode if data.value?.mode

        @$el.find('.value').text('').jqTime data.mode, _.extend {}, data.value
