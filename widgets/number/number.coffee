
class Dashboard.widgets.number extends Dashboard.widgets.standart
    initialize: ->
        @view = new Dashboard.widgets.numberView model: @

class Dashboard.widgets.numberView extends Dashboard.widgets.standartView
    className: 'widget number'

    getData: ->
        data = @model.toJSON()
        data.value = Dashboard.utils.shortenedNumber data.value

        return data
