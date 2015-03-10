
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
        @view = new Dashboard.widgets.percentageView model: @

    # Custom data schema
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
