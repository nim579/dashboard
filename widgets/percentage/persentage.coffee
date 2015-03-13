
class Dashboard.widgets.percentage extends Dashboard.widgets.standart
    defaults: ->
        return {
            label: ''
            value:
                dividend: 0
                divider: 1
        }

    initialize: ->
        @view = new Dashboard.widgets.percentageView model: @, id: @id

    getTrend: ->
        if @_previousAttributes.value
            pervious = @_previousAttributes.value
            current = @get('value')
            return (current.dividend / current.divider - pervious.dividend / pervious.divider)*100

        return 0

class Dashboard.widgets.percentageView extends Dashboard.widgets.standartView
    className: 'widget percentage'

    getData: ->
        data = @model.toJSON()
        data.value = data.value.dividend / data.value.divider
        data.value = Math.round((data.value)*10000)/100 + '%'

        return data
