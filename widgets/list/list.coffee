
class Dashboard.widgets.list extends Dashboard.widgets.standart
    initialize: ->
        @view = new Dashboard.widgets.listView model: @, id: @id

class Dashboard.widgets.listView extends Dashboard.widgets.standartView
    className: 'widget list'
    template: '''
        <% if(typeof label != \'undefined\'){ %>
            <div class="title"><%= label %></div>
        <% } %>
        <span class="value"></span>
        <% if(typeof last_update != \'undefined\'){ %>
            <div class="helpline">Last updated: <% print(Dashboard.utils.getTime(last_update)) %></div>
        <% } %>
    '''

    render: ->
        data = @getData()

        @$el.html _.template(@template) data
        table = $ '<ul></ul>'

        for row in data.value
            table.append "<li>#{row.label}</li>"

        @$el.find('.value').html table
