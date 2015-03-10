
class Dashboard.widgets.percentage extends Dashboard.widgets.standart
    defaults: ->
        return {
            label: ''
            value:
                large:
                    current: 1

                all:
                    current: 1
        }

    initialize: ->
        @view = new Dashboard.widgets.percentageView model: @, id: @id

    getTrend: ->
        if @_previousAttributes.value
            pervious = @_previousAttributes.value
            current = @get('value')
            # return (current.dividend / current.divider - pervious.dividend / pervious.divider)*100
            return (current.large.current / current.all.current - pervious.large.current / pervious.all.current)*100

        return 0

    #XXX Custom data schema
    toJSON: ->
        data = _.extend {}, @attributes

        data.value =
            dividend: data.value.large.current
            divider: data.value.all.current

        return data

class Dashboard.widgets.percentageView extends Dashboard.widgets.standartView
    className: 'widget percentage'

    getData: ->
        data = @model.toJSON()
        data.value = data.value.dividend / data.value.divider
        data.value = Math.round((data.value)*10000)/100 + '%'

        return data
