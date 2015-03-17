
class Dashboard.widgets.piechart extends Dashboard.widgets.standart
    defaults: ->
        return {
            label: ''
            value: [
                value: 1, label: '', fake: true
            ]

        }
    initialize: ->
        @view = new Dashboard.widgets.piechartView model: @, id: @id

class Dashboard.widgets.piechartView extends Dashboard.widgets.standartView
    className: 'widget piechart'
    template: '<div class="title"><%= label %></div><span class="value">!</span><% if(typeof last_update != \'undefined\'){ %><div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div><% } %>'

    initialize: ->
        @listenTo @model, 'change', ->
            if @_fakeRendered
                @render()

            else
                @updateChart()

        @listenToOnce @model, 'add', @render

    render: ->
        super()
        dataFull = @getData()

        data = dataFull.value.slice 0
        @$el.find('.value').html '<div class="pie"><canvas class="chart" width="50" height="50"></canvas></div>'

        ctx = @$el.find('.chart')[0].getContext("2d")
        ctx.canvasWidth = 200
        ctx.canvasHeight = 200
        color = d3.scale.category20()

        newData = []
        for el, i in data
            chartEl = _.extend {}, el
            chartEl.color = color(i)
            newData.push chartEl

        if dataFull.firstAll and newData[0]?.value and not newData[0].fake
            all = newData[0].value
            newData[0].value = 0

        # Lazy rendering hack
        @_fakeRendered = if newData[0]?.fake then true else false

        @chart = new Chart(ctx).Doughnut newData, _.extend {}, Chart.defaults.Doughnut, responsive: true, animateScale: false, animateRotate: false, legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%>: <em class=\"legend-value\"><%=segments[i].value%></em><%}%></li><%}%></ul>"
        
        $legend = $ @chart.generateLegend()

        if dataFull.firstAll
            $legend.find('li').eq(0).find('.legend-value').text all

        @$el.find('.value').append $legend


    updateChart: ->
        if @chart?
            dataFull = @getData()
            data = _.clone dataFull.value

            color = d3.scale.category20()

            if dataFull.firstAll and data[0]?.value
                all = data[0].value
                data[0].value = 0

            for el, i in data
                if @chart.segments[i]
                    @chart.segments[i].value = el.value

                else
                    @chart.addData _.extend {}, el, color: color(i)

            @chart.update()

            $legend = $ @chart.generateLegend()

            if dataFull.firstAll
                $legend.find('li').eq(0).find('.legend-value').text all

            @$el.find('.doughnut-legend').remove()
            @$el.find('.value').append $legend

