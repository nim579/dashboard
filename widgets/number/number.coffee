
class Dashboard.widgets.number extends Dashboard.widgets.standart
    initialize: ->
        @view = new Dashboard.widgets.numberView model: @, id: @id

    getTrend: ->
        if @_previousAttributes.value
            pervious = @_previousAttributes
            return @get('value') - pervious

        return 0

class Dashboard.widgets.numberView extends Dashboard.widgets.standartView
    className: 'widget number'

    getData: ->
        data = @model.toJSON()
        data.value = Dashboard.utils.shortenedNumber data.value

        return data
