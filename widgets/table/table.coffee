
class Dashboard.widgets.table extends Dashboard.widgets.standart
    initialize: ->
        @view = new Dashboard.widgets.tableView model: @, id: @id

class Dashboard.widgets.tableView extends Dashboard.widgets.standartView
    className: 'widget table'
    template: '<div class="title"><%= label %></div><span class="value"></span><% if(typeof last_update != \'undefined\'){ %><div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div><% } %>'

    render: ->
        data = @getData()

        @$el.html _.template(@template) data
        table = $ '<table></table>'

        for row in data.value
            table.append "<tr><td>#{row.label}</td><td>#{row.value}</td></tr>"

        @$el.find('.value').html table
