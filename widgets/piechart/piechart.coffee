
class Dashboard.widgets.piechart extends Dashboard.widgets.standart
    defaults: ->
        return {
            label: ''
            value: []

        }
    initialize: ->
        @view = new Dashboard.widgets.piechartView model: @, id: @id

class Dashboard.widgets.piechartView extends Dashboard.widgets.standartView
    className: 'widget piechart'
    template: '<div class="title"><%= label %></div><span class="value"></span><% if(typeof last_update != \'undefined\'){ %><div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div><% } %>'

    initialize: ->
        @listenTo @model, 'change', @render
        @listenToOnce @model, 'add', @render

    render: ->
        super()
        dataFull = @getData()

        data = dataFull.value.slice 0
        @$el.find('.value').html '<div class="pie"><canvas class="chart" width="50%" height="50%"></canvas></div>'

        ctx = @$el.find('.chart')[0].getContext("2d")
        ctx.canvasWidth = 200
        ctx.canvasHeight = 200
        color = d3.scale.category20()

        newData = []
        for el, i in data
            chartEl = _.extend {}, el
            chartEl.color = color(i)
            newData.push chartEl

        if dataFull.firstAll and newData[0]?.value
            all = newData[0].value
            newData[0].value = 0

        @chart = new Chart(ctx).Doughnut newData, _.extend {}, Chart.defaults.Doughnut, responsive: true, animateScale: false, animateRotate: false, legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%>: <em class=\"legend-value\"><%=segments[i].value%></em><%}%></li><%}%></ul>"
        
        $legend = $ @chart.generateLegend()
        $legend.find('li').eq(0).find('.legend-value').text all
        @$el.find('.value').append $legend


    render2: ->
        super()
        dataFull = @getData()
        data = dataFull.value

        width = $('#users').outerWidth() / 2
        height = $('#users').outerHeight() / 2
        width = 225
        height = 215
        radius = Math.min(width, height) / 2
        color = d3.scale.category20()

        node = @$el.find('.value')[0]

        $(node).children("svg").remove();

        if data.length > 0
            pieData = $.extend true, [], data
            pieData[0].value = 0 if dataFull.firstAll

            @chart = d3.select(node).append "svg:svg"
                .data [pieData]
                .attr "class", "pie"
                .attr "width", width
                .attr "height", height
                .append "svg:g"
                .attr "transform", "translate(#{radius} , #{radius})"

            #
            # Center label
            #
            if dataFull.firstAll
                label_group = @chart.append "svg:g"
                    .attr "dy", ".6em"

                center_label = label_group.append "svg:text"
                    .attr "class", "chart_label"
                    .attr "text-anchor", "middle"
                    .attr 'fill', '#ffffff'
                    .text data[0].label + ' ' + data[0].value

            arc = d3.svg.arc().innerRadius(radius * 0.6).outerRadius(radius)
            pie = d3.layout.pie().value (d)-> d.value

            arcs = @chart.selectAll "g.slice"
                .data(pie)
                .enter()
                .append "svg:g"
                .attr "class", "slice"

            arcs.append "svg:path"
                .attr "fill", (d, i) -> color(i) unless i is 0 and dataFull.firstAll
                .attr "d", arc

            @arcs = arcs

            #
            # Legend
            #
            legend = d3.select(node).append("svg:svg")
                .attr("class", "legend")
                .attr("height", (data.length + data.length * 0.2) + 'em')
                .append "svg:g"
                .attr("x", 0)
                .attr("y", 0)
                .attr("height", (data.length + data.length * 0.2) + 'em')
                .attr('width', 'auto')

            slicer = if dataFull.firstAll then 1 else 0
            legend.selectAll("g").data(data.slice(slicer))
                .enter()
                .append("g")
                .each((d, i) ->
                    g = d3.select(@)

                    g.append("rect")
                      .attr("x", 0)
                      .attr("y", (i + 0.2*i) + 'em')
                      .attr("width", '1em')
                      .attr("height", '1em')
                      .attr("fill", color(i+slicer))

                    g.append("text")
                      .attr("x", '1.3em')
                      .attr("y", (i + 0.9 + 0.2*i) + 'em')
                      .attr('fill', '#ffffff')
                      .attr('font-size', '1em')
                      .attr('line-height', '1em')
                      .attr("height", '1em')
                      .text(d.label + " " + d.value)
                )