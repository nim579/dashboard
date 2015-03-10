
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

    render: ->
        super()
        dataFull = @getData()
        data = dataFull.value

        width = 225
        height = 225
        radius = 112
        label_radius = 110
        color = d3.scale.category20()

        node = @$el.find('.value')[0]

        $(node).children("svg").remove();

        if data.length > 0
            pieData = $.extend true, [], data
            pieData[0].value = 0 if dataFull.firstAll

            chart = d3.select(node).append("svg:svg")
                .data([pieData])
                .attr("width", width)
                .attr("height", height)
                .append("svg:g")
                .attr("transform", "translate(#{radius} , #{radius})")

            #
            # Center label
            #
            if dataFull.firstAll
                label_group = chart.append("svg:g")
                    .attr("dy", ".6em")

                center_label = label_group.append("svg:text")
                    .attr("class", "chart_label")
                    .attr("text-anchor", "middle")
                    .attr('fill', '#ffffff')
                    .text(data[0].label + ' ' + data[0].value )

            arc = d3.svg.arc().innerRadius(radius * .6).outerRadius(radius)
            pie = d3.layout.pie().value((d) -> d.value)

            arcs = chart.selectAll("g.slice")
                .data(pie)
                .enter()
                .append("svg:g")
                .attr("class", "slice")

            arcs.append("svg:path")
                .attr("fill", (d, i) -> color(i) unless i is 0 and dataFull.firstAll)
                .attr("d", arc)

            #
            # Legend
            #
            rectSize = 18
            legend = d3.select(node).append("svg:svg")
                .attr("class", "legend")
                .attr("x", 0)
                .attr("y", 0)
                .attr("height", (rectSize + 4) * data.length)
                .attr('width', '380')

            legend.selectAll("g").data(data)
                .enter()
                .append("g")
                .each((d, i) ->
                    return if i is 0 and dataFull.firstAll
                    g = d3.select(@)

                    g.append("rect")
                      .attr("x", 0)
                      .attr("y", i * (rectSize + 4))
                      .attr("width", rectSize - 1)
                      .attr("height", rectSize - 1)
                      .attr("fill", color(i))

                    g.append("text")
                      .attr("x", rectSize + 4)
                      .attr("y", (i + 1) * (rectSize + 4) - 6)
                      .attr("font-size", "#{rectSize - 1}px")
                      .attr('fill', '#ffffff')
                      .text(d.label + " " + d.value)
                )