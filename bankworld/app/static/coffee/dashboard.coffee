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

#    legend = svg.append('g')
#    legend.append("text").attr("x", @width/2)
#    .attr("y", @height + (@margin.bottom/2)+ 5).attr("class", "legend").style("stroke", "red")
#    .text("Down but should be up")
#    legend.append("text").attr("x", @width/2)
#    .attr("y", @height + (@margin.bottom/2)+ 15).attr("class", "legend").style("stroke", "royalblue")
#    .text("Up but should be Down")

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
      ).style("stroke", "black").attr("fill", "white").text((d) -> d.businessunit).on("click", (d) =>
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
    svg.selectAll("circle").data(data.filter( (d) => +d.activityflag == activityflag))
    .enter().append('circle').attr(
      cx: (d) => x(d.timestamp)
      cy: (d) => y(+d.numipaddr)
      r: 1
    ).style('stroke',"steelblue")

    svg.selectAll('circle').on("mouseover", () -> d3.select(this).transition().attr('r',5))
    svg.selectAll('circle').on("mouseout", () -> d3.select(this).transition().attr('r',1))

    svg.selectAll('circle').on("mouseover.tooltip",
    (d) =>
      svg.select('#data_id').remove()
      svg.append('text').text(d.numipaddr).attr('x', x(d.timestamp)+10).attr('y', y(d.numipaddr)+10).attr('id', 'data_id')
    )
    svg.selectAll('circle').on("mouseout.tooltip",
    (d) => svg.select('#data_id').transition().duration(20).style('opacity',0).attr('transform','translate(10,-10)').remove())


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
    .text("Activity " + activityflag);

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
    @policystatus = [5]

  draw: (region="headquarters", data=null) ->
    @curregion = region
    policystatus = @policystatus

    button = d3.select(@parent).selectAll("button").data(["1", "2", "3", "4","5"])
    .enter().append('button').attr("type", "button").attr("class", "btn btn-primary btn-xs").text((d) -> d)

    button.on("click", (d) =>
#      if +d not in @policystatus then @policystatus.push(+d)
      @policystatus = [+d]
      @draw(@curregion, @data))

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
    y.domain(d3.extent(data.filter( (d) => +d.policystatus in policystatus), (d) -> +d.numipaddr))

    svg.append("path").datum(data.filter( (d) => +d.policystatus in policystatus)).attr("class", "line").attr("d", line)

    svg.selectAll("line").data(data.filter( (d) => +d.policystatus in policystatus)).enter()
    .append('line').attr(
      x1: (d) => x(d.timestamp)
      y1: 0
      x2: (d) => x(d.timestamp)
      y2: @height,
    )
#    .attr(
#      'stroke': 'white'
#      'stroke-width' : '10px')
    svg.selectAll("circle").data(data.filter( (d) => +d.policystatus in policystatus))
    .enter().append('circle').attr(
      cx: (d) => x(d.timestamp)
      cy: (d) => y(+d.numipaddr)
      r: 1
    ).style('stroke',"steelblue")

    svg.selectAll('circle').on("mouseover", () -> d3.select(this).transition().attr('r',5))
    svg.selectAll('circle').on("mouseout", () -> d3.select(this).transition().attr('r',1))

    svg.selectAll('line').on("mouseover", () -> d3.select(this).transition().attr('stroke', 'red'))
    svg.selectAll('line').on("mouseout", () -> d3.select(this).transition().attr('stroke', 'white'))
    svg.selectAll('line').on("mouseover.tooltip",
    (d) =>
      svg.select('#data_id').remove()
      svg.append('text').text(d.numipaddr).attr('x', x(d.timestamp)+10).attr('y', y(d.numipaddr)+10).attr('id', 'data_id')
    )
    svg.selectAll('line').on("mouseout.tooltip",
    (d) => svg.select('#data_id').transition().duration(20).style('opacity',0).attr('transform','translate(10,-10)').remove())

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
    .text("Policy " + policystatus);

class BWDashboard
  constructor: (parent="body") ->
    @setupEventDispatch()
    @setupFrame()
    @setupPlots()
    @loadData()

  setupEventDispatch: ->
    @evdispatch = d3.dispatch("load", "selectRegion", "selectTime", "attime")

  #TODO: Change it to json based grid format
  setupFrame: ->
    console.log("here")

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

    @bw_ws_teller_conn_chart = new MultiLineChart(560,200,"#bw_ws_teller_conn_chart", "Teller Machine Connections")
    @evdispatch.on("selectRegion.bw_ws_teller_conn_chart", (region) => @bw_ws_teller_conn_chart.draw(region))
    @evdispatch.on("selectTime.bw_ws_teller_conn_chart", (start,end) => @bw_ws_teller_conn_chart.draw(null, null,start,end))

    @bw_ws_loan_conn_chart = new MultiLineChart(560,200,"#bw_ws_loan_conn_chart", "Loan Machine Connections")
    @evdispatch.on("selectRegion.bw_ws_loan_conn_chart", (region) => @bw_ws_loan_conn_chart.draw(region))
    @evdispatch.on("selectTime.bw_ws_loan_conn_chart", (start,end) => @bw_ws_loan_conn_chart.draw(null, null,start,end))

    @bw_ws_office_conn_chart = new MultiLineChart(560,200,"#bw_ws_office_conn_chart", "Office Machine Connections")
    @evdispatch.on("selectRegion.bw_ws_office_conn_chart", (region) => @bw_ws_office_conn_chart.draw(region))
    @evdispatch.on("selectTime.bw_ws_office_conn_chart", (start,end) => @bw_ws_office_conn_chart.draw(null, null,start,end))

    @bw_activity_chart = new MultiTimeSeriesChart(760,200,"#bw_activity_chart","Activity Flag",@evdispatch)
    @evdispatch.on("selectRegion.activity", (region) => @bw_activity_chart.draw(region))

    @bw_policy_chart = new MultiTimeSeriesPolicyChart(760,200,"#bw_policy_chart","Policy Flag",@evdispatch)
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
        $("#start_time").attr("value", start_date.toString())
        $("#end_time").attr("value", end_date.toString())
        @evdispatch.selectTime(start_date, end_date)
        console.log(start_date.toString())
        console.log(end_date.toString())
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
        $("#at_time").attr("value", start_date.toString())
        @evdispatch.attime(start_date)
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
      @bw_ws_teller_conn_chart.draw("headquarters", data)
    )
    d3.csv('/static/csv/ws_loan_connection.csv', (error, data) =>
      @bw_ws_loan_conn_chart.draw("headquarters", data)
    )
    d3.csv('/static/csv/ws_office_connection.csv', (error, data) =>
      @bw_ws_office_conn_chart.draw("headquarters", data)
    )
    d3.csv('/static/csv/activity12345_status.csv', (error, data) =>
      @bw_activity_chart.draw("headquarters", 5, data)
    )
    d3.csv('/static/csv/policy12345_status.csv', (error, data) =>
      @bw_policy_chart.draw("headquarters", data)
    )

b = new BWDashboard()


