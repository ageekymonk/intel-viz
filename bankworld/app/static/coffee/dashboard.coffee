'use strict'

class DifferenceChart
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

    x = d3.time.scale().range([0,@width])
    y = d3.scale.linear().range([@height,0])
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")
    line = d3.svg.area().interpolate("step").x( (d) -> x(d.timestamp)).y((d) -> y(d.expected))
    area = d3.svg.area().interpolate("step").x( (d) -> x(d.timestamp)).y((d) -> y(d.expected))

    zoom = d3.behavior.zoom().on("zoom", () =>
      console.log(d3.event.scale)
      svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
    ).scaleExtent([1,5])

    d3.select(@parent).selectAll("svg").remove()
    svg = d3.select(@parent).append('svg').attr(
      width : @width + @margin.left + @margin.right,
      height : @height + @margin.top + @margin.bottom
    ).append('g').attr("transform","translate("+@margin.left + ","+@margin.top+")").call(zoom)

    x.domain(d3.extent(data, (d) -> d.timestamp))
#    y.domain([d3.min(data, (d) -> Math.min(d.expected, d.reported)), d3.max(data, (d) -> Math.max(d.expected, d.reported))])
    y.domain([0, d3.max(data, (d) -> Math.max(d.expected, d.reported))])

    svg.datum(data)
#    svg.append("clipPath")
#    .attr("id", "clip-below")
#    .append("path")
#    .attr("d", area.y0(@height)).style("fill" , "blue")
#
#    svg.append("clipPath")
#    .attr("id", "clip-above")
#    .append("path")
#    .attr("d", area.y0(0)).style("fill" , "blue")
#
#    svg.append("path")
#    .attr("class", "area above")
#    .attr("clip-path", (d) -> "url(#clip-above)")
#    .attr("d", area.y0((d) ->y(d.reported)))
#
#    svg.append("path")
#    .attr("class", "area below")
#    .attr("clip-path", (d) -> "url(#clip-below)")
#    .attr("d", area)
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

    svg.append("path")
    .attr("class", "line")
    .attr("d", line.y((d) -> y(d.reported)))

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
#    .text("Unexpected On Machines")

    svg.append("text")
    .attr("x", (@width / 2))
    .attr("y", 0 - (@margin.top / 2))
    .attr("text-anchor", "middle")
    .style("font-size", "12px")
    .style("text-decoration", "underline")
    .text(@title);

    legend = svg.append('g')
    legend.append("text").attr("x", @width/2)
    .attr("y", @height + (@margin.bottom/2)+ 5).attr("class", "legend").style("stroke", "green")
    .text("Down but should be up")
    legend.append("text").attr("x", @width/2)
    .attr("y", @height + (@margin.bottom/2)+ 15).attr("class", "legend").style("stroke", "red")
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
    line = d3.svg.area().interpolate("basis").x( (d) -> x(d.timestamp)).y((d) -> y(+d.avgconn))

    d3.select(@parent).selectAll("svg").remove()
    svg = d3.select(@parent).append('svg').attr(
      width : @width + @margin.left + @margin.right,
      height : @height + @margin.top + @margin.bottom
    ).append('g').attr("transform","translate("+@margin.left + ","+@margin.top+")")

    x.domain(d3.extent(data, (d) -> d.timestamp))
    #    y.domain([d3.min(data, (d) -> Math.min(d.expected, d.reported)), d3.max(data, (d) -> Math.max(d.expected, d.reported))])
    y.domain([0, 50])

    svg.append("path").datum(data).attr("class", "line").attr("d", line)
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
    #    .text("Unexpected On Machines")

    svg.append("text")
    .attr("x", (@width / 2))
    .attr("y", 0 - (@margin.top / 2))
    .attr("text-anchor", "middle")
    .style("font-size", "12px")
    .style("text-decoration", "underline")
    .text(@title);

    legend = svg.append('g')
    legend.append("text").attr("x", @width/2)
    .attr("y", @height + (@margin.bottom/2)+ 5).attr("class", "legend").style("stroke", "green")
    .text("Down but should be up")
    legend.append("text").attr("x", @width/2)
    .attr("y", @height + (@margin.bottom/2)+ 15).attr("class", "legend").style("stroke", "red")
    .text("Up but should be Down")

class BWMap
  constructor: (width=400, height=300, parent="body",evDispatch) ->
    @width = width
    @height = height
    @evDispatch = evDispatch
    @projection = d3.geo.equirectangular()
    @svg = d3.select(parent).append("svg").attr(
      width: @width
      height: @height
    )

  draw: ->
    d3.csv('/static/csv/branch_lat_long.csv').get((error, world) =>
      world.forEach( (d) =>
        [d.x1,d.y1] = @projection([d.minlong,d.maxlat])
        [d.x2,d.y2] = @projection([d.maxlong,d.minlat])

        d.width =  if (d.x2 - d.x1) == 0 then 5 else (d.x2 - d.x1)
        d.height = if (d.y2 - d.y1) == 0 then 5 else (d.y2 - d.y1)
      )

      @svg.selectAll(".area").data(world)
      .enter().append("rect", ".area")
      .attr(
        x: (d) -> d.x1
        y: (d) -> d.y1
        width: (d) -> d.width
        height: (d) -> d.height
        id: (d) -> "bu_"+d.businessunit
      ).style("stroke", "black").attr("fill", "white").on("click", (d) =>
        @evDispatch.selectRegion(d.businessunit))

      d3.select(self.frameElement).style("height", @height + "px")
    )

class BWSpreadMap
  constructor: (width=400, height=300, parent="body",evDispatch) ->
    @width = width
    @height = height
    @evDispatch = evDispatch
    @projection = d3.geo.equirectangular()
    @svg = d3.select(parent).append("svg").attr(
      width: @width
      height: @height
    )

  draw: ->
    d3.csv('/static/csv/branch_lat_long.csv').get((error, world) =>
      world.forEach( (d) =>
        [d.x1,d.y1] = @projection([d.minlong,d.maxlat])
        [d.x2,d.y2] = @projection([d.maxlong,d.minlat])

        d.width =  if (d.x2 - d.x1) == 0 then 5 else (d.x2 - d.x1)
        d.height = if (d.y2 - d.y1) == 0 then 5 else (d.y2 - d.y1)
      )

      @svg.selectAll(".area").data(world)
      .enter().append("rect", ".area")
      .attr(
        x: (d) -> d.x1
        y: (d) -> d.y1
        width: (d) -> d.width
        height: (d) -> d.height
        id: (d) -> "bu_"+d.businessunit
      ).style("stroke", "black").attr("fill", "white").on("click", (d) =>
        @evDispatch.selectRegion(d.businessunit))

      d3.select(self.frameElement).style("height", @height + "px")
    )

  virusSpread: ->
    d3.csv('/static/csv/policy5_status.csv').get((error,virusdata) =>
      dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
      virusdata.forEach( (d) =>
        d.timestamp = dateFormat.parse(d.healthtime)
      )

      virusdata.forEach( (vd) =>
        if +vd.numipaddr > 0
          data = @svg.select("#bu_"+vd.businessunit).datum()
          console.log([1..1+(+vd.numipaddr/10)])
          @svg.selectAll("circle").data([1..1+(+vd.numipaddr/10)]).enter().append("circle").attr(
            cx: (d) => data.x1 + data.width/2 + d*2
            cy: (d) => data.y1 + data.height/2 + d*2
            r: 2
          ).style("fill","steelblue")
      )

    )

class MultiTimeSeriesChart
  constructor: (w, h, parent="body", title = "", evDispatch) ->
    @margin = {top: 20, right: 20, bottom: 50, left: 50}
    @width = w - @margin.left - @margin.right
    @height = h - @margin.top - @margin.bottom
    @parent = parent
    @data = null
    @title = title
    @evDispatch = evDispatch
    @curregion = "headquarters"


  draw: (region="headquarters", activityflag = 5, data=null) ->
    @curregion = region
    button = d3.select(@parent).selectAll("button").data(["1", "2", "3", "4","5"])
    .enter().append('button').attr("type", "button").attr("class", "btn btn-primary btn-xs").text((d) -> d)

    button.on("click", (d) =>
      console.log(@curregion)
      @draw(@curregion,+d, @data))

    data = if data is null then @data else data
    @data = data
    dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
    data = data.filter( (d) => d.businessunit == region)
    data.forEach( (d) ->
      d.timestamp = dateFormat.parse(d.healthtime)
    )

    x = d3.time.scale().range([0,@width])
    y = d3.scale.linear().range([@height,0])
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")
    line = d3.svg.line().x( (d) -> x(d.timestamp)).y((d) -> y(+d.numipaddr))

    d3.select(@parent).selectAll("svg").remove()
    svg = d3.select(@parent).append('svg').attr(
      width : @width + @margin.left + @margin.right,
      height : @height + @margin.top + @margin.bottom
    ).append('g').attr("transform","translate("+@margin.left + ","+@margin.top+")")

    x.domain(d3.extent(data, (d) -> d.timestamp))
    y.domain(d3.extent(data.filter( (d) => +d.activityflag == activityflag), (d) -> +d.numipaddr))

    svg.append("path").datum(data.filter( (d) => +d.activityflag == activityflag)).attr("class", "line").attr("d", line)

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
    #    .text("Unexpected On Machines")

    svg.append("text")
    .attr("x", (@width / 2))
    .attr("y", 0 - (@margin.top / 2))
    .attr("text-anchor", "middle")
    .style("font-size", "12px")
    .style("text-decoration", "underline")
    .text(@title);

#    legend = svg.append('g')
#    legend.append("text").attr("x", @width/2)
#    .attr("y", @height + (@margin.bottom/2)+ 5).attr("class", "legend").style("stroke", "green")
#    .text("Down but should be up")
#    legend.append("text").attr("x", @width/2)
#    .attr("y", @height + (@margin.bottom/2)+ 15).attr("class", "legend").style("stroke", "red")
#    .text("Up but should be Down")

class MultiTimeSeriesPolicyChart
  constructor: (w, h, parent="body", title = "", evDispatch) ->
    @margin = {top: 20, right: 20, bottom: 50, left: 50}
    @width = w - @margin.left - @margin.right
    @height = h - @margin.top - @margin.bottom
    @parent = parent
    @data = null
    @title = title
    @evDispatch = evDispatch
    @curregion = "headquarters"

  draw: (region="headquarters", policystatus = 5, data=null) ->
    @curregion = region
    button = d3.select(@parent).selectAll("button").data(["1", "2", "3", "4","5"])
    .enter().append('button').attr("type", "button").attr("class", "btn btn-primary btn-xs").text((d) -> d)

    button.on("click", (d) =>
      console.log(@curregion)
      @draw(@curregion,+d, @data))

    data = if data is null then @data else data
    @data = data
    dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
    data = data.filter( (d) => d.businessunit == region)
    data.forEach( (d) ->
      d.timestamp = dateFormat.parse(d.healthtime)
    )

    x = d3.time.scale().range([0,@width])
    y = d3.scale.linear().range([@height,0])
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")
    line = d3.svg.line().x( (d) -> x(d.timestamp)).y((d) -> y(+d.numipaddr))

    d3.select(@parent).selectAll("svg").remove()
    svg = d3.select(@parent).append('svg').attr(
      width : @width + @margin.left + @margin.right,
      height : @height + @margin.top + @margin.bottom
    ).append('g').attr("transform","translate("+@margin.left + ","+@margin.top+")")

    x.domain(d3.extent(data, (d) -> d.timestamp))
    y.domain(d3.extent(data.filter( (d) => +d.policystatus == policystatus), (d) -> +d.numipaddr))

    svg.append("path").datum(data.filter( (d) => +d.policystatus == policystatus)).attr("class", "line").attr("d", line)

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
#    .text("Unexpected On Machines")

    svg.append("text")
    .attr("x", (@width / 2))
    .attr("y", 0 - (@margin.top / 2))
    .attr("text-anchor", "middle")
    .style("font-size", "12px")
    .style("text-decoration", "underline")
    .text(@title);

#    legend = svg.append('g')
#    legend.append("text").attr("x", @width/2)
#    .attr("y", @height + (@margin.bottom/2)+ 5).attr("class", "legend").style("stroke", "green")
#    .text("Down but should be up")
#    legend.append("text").attr("x", @width/2)
#    .attr("y", @height + (@margin.bottom/2)+ 15).attr("class", "legend").style("stroke", "red")
#    .text("Up but should be Down")


class BWDashboard
  constructor: (parent="body") ->
    @setupEventDispatch()
    @setupFrame()
    @setupPlots()
    @loadData()

  setupEventDispatch: ->
    @evdispatch = d3.dispatch("load", "selectRegion", "selectTime")

  #TODO: Change it to json based grid format
  setupFrame: ->
    console.log("here")

  setupPlots: ->
    @bw_map_selector = new BWMap(400,300,"#bw_map_selector",@evdispatch)
    @bw_map_selector.draw()

    @bw_ws_reported_chart = new DifferenceChart(560,200,"#bw_ws_reported_chart", "Expected vs Reported Workstations")
    @bw_server_reported_chart = new DifferenceChart(560,200,"#bw_server_reported_chart", "Expected vs Reported Servers")
    @bw_atm_reported_chart = new DifferenceChart(560,200,"#bw_atm_reported_chart", "Expected vs Reported ATM")

    @evdispatch.on("selectRegion.ws", (region) => @bw_ws_reported_chart.draw(region))
    @evdispatch.on("selectTime.ws", (start,end) => @bw_ws_reported_chart.draw(null, null,start,end))

    @evdispatch.on("selectRegion.server", (region) => @bw_server_reported_chart.draw(region))
    @evdispatch.on("selectTime.server", (start,end) => @bw_server_reported_chart.draw(null, null,start,end))

    @evdispatch.on("selectRegion.atm", (region) => @bw_atm_reported_chart.draw(region))
    @evdispatch.on("selectTime.atm", (start,end) => @bw_atm_reported_chart.draw(null, null,start,end))

    @bw_conn_chart = new MultiLineChart(560,200,"#bw_conn_chart", "Num Connections")
    @evdispatch.on("selectRegion.bwconn", (region) => @bw_conn_chart.draw(region))
    @evdispatch.on("selectTime.bwconn", (start,end) => @bw_conn_chart.draw(null, null,start,end))

    @bw_activity_chart = new MultiTimeSeriesChart(560,200,"#bw_activity_chart","Activity Flag",@evdispatch)
    @evdispatch.on("selectRegion.activity", (region) => @bw_activity_chart.draw(region))

    @bw_policy_chart = new MultiTimeSeriesPolicyChart(560,200,"#bw_policy_chart","Policy Flag",@evdispatch)
    @evdispatch.on("selectRegion.policy", (region) => @bw_policy_chart.draw(region))

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
        $("#start_time").text(start_date.toString())
        $("#end_time").text(end_date.toString())
        @evdispatch.selectTime(start_date, end_date)
        console.log(start_date.toString())
        console.log(end_date.toString())
    )

  loadData: ->
    d3.csv('/static/csv/ws_teller_report_status.csv', (error, data) =>
      @bw_ws_reported_chart.draw("headquarters", data)
    )
    d3.csv('/static/csv/server_report_status.csv', (error, data) =>
      @bw_server_reported_chart.draw("headquarters", data)
    )
    d3.csv('/static/csv/atm_report_status.csv', (error, data) =>
      @bw_atm_reported_chart.draw("headquarters", data)
    )
    d3.csv('/static/csv/ws_teller_connection.csv', (error, data) =>
      @bw_conn_chart.draw("headquarters", data)
    )
    d3.csv('/static/csv/activity12345_status.csv', (error, data) =>
      @bw_activity_chart.draw("headquarters", 5, data)
    )
    d3.csv('/static/csv/policy12345_status.csv', (error, data) =>
      @bw_policy_chart.draw("headquarters", 5, data)
    )

b = new BWDashboard()


