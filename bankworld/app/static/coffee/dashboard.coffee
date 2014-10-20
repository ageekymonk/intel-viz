'use strict'

class DifferenceChart
  constructor: (w, h, parent="body", title = "", evDispatch) ->
    @margin = {top: 20, right: 40, bottom: 70, left: 70}
    @width = w - @margin.left - @margin.right
    @height = h - @margin.top - @margin.bottom
    @parent = parent
    @data = null
    @title = title
    @evDispatch = evDispatch
    @curregion = "headquarters"

  draw: (region=null, data=null, start_time=null, end_time=null) ->
    if region is null
      region = @curregion

    @curregion = region

    data = if data is null then @data else data
    @data = data
    dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")

    data = data.filter( (d) => d.businessunit == region )

    data.forEach( (d) =>
      d.timestamp = dateFormat.parse(d.healthtime)
      d.expected = +d.expected
      d.reported = +d.reported
    )

    data = data.filter( (d) =>
      if start_time != null and end_time != null
        start_time <= d.timestamp <= end_time
      else
        true
    )

    if data.length == 0
      return


    x = d3.time.scale().range([0,@width])
    y = d3.scale.linear().range([@height,0])
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")
    line = d3.svg.area().interpolate("step").x( (d) -> x(d.timestamp)).y((d) -> y(d.expected))
    area = d3.svg.area().interpolate("step").x( (d) -> x(d.timestamp)).y((d) -> y(d.expected))

    d3.select(@parent).selectAll("svg").remove()
    canvas = d3.select(@parent).append('svg').attr(
      width : @width + @margin.left + @margin.right,
      height : @height + @margin.top + @margin.bottom
    )
    svg = canvas.append('g').attr("transform","translate("+@margin.left + ","+@margin.top+")")

    x.domain(d3.extent(data, (d) -> d.timestamp))
    y.domain([0, d3.max(data, (d) -> Math.max(d.expected, d.reported))])

    svg.datum(data)
    svg.append("path")
    .attr("class", "area below")
    .attr("d", area.y0((d) -> if d.expected >= d.reported then y(d.reported) else y(0)).y1( (d) ->
        if d.expected >= d.reported then y(d.expected) else y(0)
      ))
    svg.append("path")
    .attr("class", "area above")
    .attr("d", area.y0((d) -> if d.expected < d.reported then y(d.expected) else y(0)).y1( (d) ->
        if d.expected < d.reported then y(d.reported) else y(0)
      ))
    svg.append("path")
    .attr("class", "line")
    .attr("d", line)

    svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + @height + ")")
    .call(xAxis)

    svg.append("g")
    .attr("class", "y axis")
    .call(yAxis)

    canvas.append("text")
    .attr("transform", "translate(0,30) rotate(-90)")
    .attr("y", 10)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("Machine Count")

    svg.append("text")
    .attr("x", (@width / 2))
    .attr("y", 0 - (@margin.top / 2))
    .attr("text-anchor", "middle")
    .attr("class", "chart-title")
    .text(@title);

    legend = svg.append('g')
    legend.append("text").attr("x", @width/2)
    .attr("y", @height + (@margin.bottom/2)+ 5).attr("class", "legend")
    .style(
      stroke: "red"
      "stroke-width": "1px")
    .text("Down but should be up")
    legend.append("text").attr("x", @width/2)
    .attr("y", @height + (@margin.bottom/2)+ 15).attr("class", "legend").style("stroke", "#118bff")
    .text("Up but should be Down")

#    svg.select("g.x.axis").selectAll("g.tick").select("text").attr("transform", "rotate(-90)translate(-20,0)")

class MultiLineChart
  constructor: (w, h, parent="body", title = "", evDispatch) ->
    @margin = {top: 20, right: 20, bottom: 70, left: 50}
    @width = w - @margin.left - @margin.right
    @height = h - @margin.top - @margin.bottom
    @parent = parent
    @data = null
    @title = title
    @evDispatch = evDispatch
    @curregion = "headquarters"

  draw: (region=null, data=null, start_time=null, end_time=null) ->
    if region is null
      region = @curregion

    @curregion = region
    data = if data is null then @data else data
    @data = data
    dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
    data = data.filter( (d) => d.businessunit == region)
    data.forEach( (d) ->
      d.timestamp = dateFormat.parse(d.healthtime)
      d.expected = +d.expected
      d.reported = +d.reported
    )

    data = data.filter( (d) =>
      if start_time != null and end_time != null
        start_time <= d.timestamp <= end_time
      else
        true
    )

    x = d3.time.scale().range([0,@width])
    y = d3.scale.linear().range([@height,0])
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")
    line = d3.svg.area().interpolate("basis").x( (d) -> x(new Date(d.timestamp.getTime() - +d.lag*60*60*1000))).y((d) -> y(+d.avgconn))
    workzone = d3.svg.area().interpolate("basis").x( (d) -> x(d.timestamp)).y((d) =>
      time = new Date(d.timestamp.getTime() - d.lag*60*60*1000)
      if time.getHours() >=7 and time.getHours() < 18 then 0 else @height)

    d3.select(@parent).selectAll("svg").remove()
    canvas = d3.select(@parent).append('svg').attr(
      width : @width + @margin.left + @margin.right,
      height : @height + @margin.top + @margin.bottom
    )
    svg = canvas.append('g').attr("transform","translate("+@margin.left + ","+@margin.top+")")

    x.domain(d3.extent(data, (d) -> new Date(d.timestamp.getTime() - +d.lag*60*60*1000)))
    y.domain(d3.extent(data, (d)-> +d.avgconn))
#    y.domain([0, 50])

    svg.append("path").datum(data).attr("class", "line").attr("d", line)
    svg.datum(data).append("path").attr("fill", "red").attr("d", workzone)
#    svg.selectAll("circle").data(data).enter().append("circle")
#    .attr("cx", (d) -> x(d.timestamp))
#    .attr("cy", (d,i) -> y(d.avgconn))
#    .attr("r", (d) -> "1px").style("stroke", "blue")

    svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + @height + ")")
    .call(xAxis)

    svg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 6)
    .attr("dy", ".71em")
    .style("text-anchor", "end")

    canvas.append("text")
    .attr("transform", "translate(0,30) rotate(-90)")
    .attr("y", 10)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("Average Connections")

    svg.append("text")
    .attr("x", (@width / 2))
    .attr("y", 0 - (@margin.top / 2))
    .attr("text-anchor", "middle")
    .attr("class","chart-title")
    .text(@title);


class BWDashboard
  constructor: (parent="body") ->
    @setupEventDispatch()
    @setupPlots()
    @loadData()
    @curtime = 1
    @playinterval = 1

  setupEventDispatch: ->
    @evdispatch = d3.dispatch("load", "selectRegion", "selectTime", "attime")

  setupPlots: ->
    @bw_map_selector = new BWMap(400,300,"#bw_map_selector",@evdispatch)
#    @bw_map_selector.draw()
    @evdispatch.on("attime.map", (time) => @bw_map_selector.draw(time))
    @bw_map_selector.load()

    @bw_map_for_spread = new BWMapVirus(400,300,"#bw_map_for_spread",@evdispatch)
    #    @bw_map_selector.draw()
    @evdispatch.on("attime.mapspread", (time) => @bw_map_for_spread.draw(time))
    @bw_map_for_spread.load()

    @bw_ws_reported_chart = new DifferenceChart(560,200,"#bw_ws_reported_chart", "Expected vs Reported Workstations")
    @bw_server_reported_chart = new DifferenceChart(560,200,"#bw_server_reported_chart", "Expected vs Reported Servers")
    @bw_atm_reported_chart = new DifferenceChart(560,200,"#bw_atm_reported_chart", "Expected vs Reported ATM")

    @evdispatch.on("selectRegion.ws", (region) => @bw_ws_reported_chart.draw(region))
    @evdispatch.on("selectTime.ws", (start,end) => @bw_ws_reported_chart.draw(null, null,start,end))

    @evdispatch.on("selectRegion.server", (region) => @bw_server_reported_chart.draw(region))
    @evdispatch.on("selectTime.server", (start,end) => @bw_server_reported_chart.draw(null, null,start,end))

    @evdispatch.on("selectRegion.atm", (region) => @bw_atm_reported_chart.draw(region))
    @evdispatch.on("selectTime.atm", (start,end) => @bw_atm_reported_chart.draw(null, null,start,end))

    @bw_ws_conn_chart = new WsConnectionsChart(760,200,"#bw_ws_conn_chart", "WS Connections")
    @evdispatch.on("selectRegion.bw_ws_conn_chart", (region) => @bw_ws_conn_chart.draw(region))
    @evdispatch.on("selectTime.bw_ws_conn_chart", (start,end) => @bw_ws_conn_chart.draw(null))

    @bw_server_conn_chart = new ServerConnectionsChart(760,200,"#bw_server_conn_chart", "Server Connections")
    @evdispatch.on("selectRegion.bw_server_conn_chart", (region) => @bw_server_conn_chart.draw(region))
    @evdispatch.on("selectTime.bw_server_conn_chart", (start,end) => @bw_server_conn_chart.draw(null))

    @bw_policy_chart = new MultiTimeSeriesPolicyChart(760,200,"#bw_policy_chart","Policy & Activity Flag",@evdispatch)
    @evdispatch.on("selectRegion.policy", (region) => @bw_policy_chart.draw(region))

    @heatmap = new HeatMap(1400,900,'#global_heat_map')
    d3.tsv('/static/csv/everything_2_glob_lat.csv', (d)=>
      d3.csv('/static/csv/heat_latlong.csv', (c)=>
        @heatmap.load d,c
        @heatmap.draw() ))

    $("#slider-range" ).slider(
      range: true,
      min: 0,
      max: 192,
      step: 1,
      values: [ 0,192 ],
      slide: ( event, ui ) =>
        dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
        start_date = new Date(dateFormat.parse("2012-02-02 08:00:00").getTime() + +ui.values[0]*60000*15)
        end_date = new Date(dateFormat.parse("2012-02-04 08:00:00").getTime() - (192 - +ui.values[1])*60000*15)
        $("#start_time").attr("value", start_date.toString())
        $("#end_time").attr("value", end_date.toString())
#        @evdispatch.selectTime(start_date, end_date)
        @heatmap.draw(start_date, end_date, ui.values[1] - ui.values[0])

    )

    $("#timeslider" ).slider(
      range: "max",
      min: 0,
      max: 192,
      step: 1,
      value: 0,
      slide: ( event, ui ) =>
        dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
        start_date = new Date(dateFormat.parse("2012-02-02 08:00:00").getTime() + +ui.value*60000*15)
        $("#attime").val(start_date.toString())
        @evdispatch.attime(start_date)
    )

    $("#play").button({
      text: false,
      icons: {primary: "ui-icon-play"}}
    ).click( () =>
      @playinterval = setInterval( () =>
        dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
        start_date = new Date(dateFormat.parse("2012-02-02 08:00:00").getTime() + @curtime*60000*15)
        $("#attime").val(start_date.toString())
        @evdispatch.attime(start_date)
        @curtime = @curtime + 1
        if @curtime > 192 then @curtime = 1
      , 200)
    )

    $("#stop").button({
        text: false,
        icons: {
          primary: "ui-icon-stop"
        }
      }
    ).click( () =>
      clearInterval(@playinterval)
    )
  loadData: ->
#    d3.csv('/static/csv/ws_report_status_new.csv', (error, data) =>
#      @bw_ws_reported_chart.draw("headquarters", data)
#    )
#    d3.csv('/static/csv/server_report_status.csv', (error, data) =>
#      @bw_server_reported_chart.draw("headquarters", data)
#    )
#    d3.csv('/static/csv/atm_report_status.csv', (error, data) =>
#      @bw_atm_reported_chart.draw("headquarters", data)
#    )
#    d3.csv('/static/csv/ws_connection_new.csv', (error, data) =>
#      @bw_ws_conn_chart.load(data)
#      @bw_ws_conn_chart.draw("headquarters", data)
#    )
#    d3.csv('/static/csv/server_connection_new.csv', (error, data) =>
#      @bw_server_conn_chart.load(data)
#      @bw_server_conn_chart.draw("headquarters", data)
#    )
#    d3.csv('/static/csv/overall_policy_activity_status_new.csv', (error, data) =>
#      @bw_policy_chart.load(data)
#      @bw_policy_chart.draw("headquarters")
#    )

b = new BWDashboard()


