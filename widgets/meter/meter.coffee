
class Dashboard.widgets.meter extends Dashboard.widgets.standart
    initialize: ->
        @view = new Dashboard.widgets.meterView model: @

class Dashboard.widgets.meterView extends Dashboard.widgets.standartView
    className: 'widget meter'
    template: '<div class="title"><%= label %></div><input type="text" class="value" value="<%= value %>"><% if(typeof last_update != \'undefined\'){ %><div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div><% } %>'

    render: ->
        super()

        data = @getData()
        @$el.find('.value').knob
            angleArc: 270
            angleOffset: 225
            readOnly: true
            max: data.mas
            value: data.value
            fgColor: @$el.find('.value').css 'color'
            bgColor: @$el.find('.value').css 'background-color'