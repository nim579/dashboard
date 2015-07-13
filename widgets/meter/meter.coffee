
class Dashboard.widgets.meter extends Dashboard.widgets.standart
    initialize: ->
        @view = new Dashboard.widgets.meterView model: @, id: @id

class Dashboard.widgets.meterView extends Dashboard.widgets.standartView
    className: 'widget meter'
    template: '''
        <div class="title"><%= label %></div>
        
        <div class="meter-progress" max="<%= max %>" value="<%= value %>">
            <div class="meter-progress-bar" style="width: <%= percents %>%;"></div>
        </div>
        <div class="meter-nums">
            <% if(typeof extra !== 'undefined' && extra.show_numbers){ %><%= nums.value %> / <%= nums.max %> — <% } %><%= nums.percents %>%
        </div>

        <% if(typeof last_update != \'undefined\'){ %>
            <div class="helpline">Last updated: <% print(Dashboard.utils.getTime(last_update)) %></div>
        <% } %>
    '''

    getData: ->
        data = @model.toJSON()

        data.percents = data.value / data.max  * 100
        data.nums =
            value: Dashboard.utils.shortenedNumber data.value
            max: Dashboard.utils.shortenedNumber data.max
            percents: (data.value / data.max * 100).toFixed(2)

        return data

    render: ->
        super()

        data = @getData()
