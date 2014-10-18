
class WsConnectionsChart
  constructor: (w, h, parent="body", title = "", evDispatch) ->
    @margin = {top: 20, right: 60, bottom: 50, left: 60}
    @width = w - @margin.left - @margin.right
    @height = h - @margin.top - @margin.bottom
    @parent = parent
    @allbudata = null
    @title = title
    @evDispatch = evDispatch
    @curregion = "headquarters"
    @policystatus = ["teller", "loan", "office"]

  load: (data) ->
    @allbudata = data
    dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
    @allbudata.forEach( (d) ->
      d.timestamp = dateFormat.parse(d.healthtime)
    )

  draw: (region="headquarters") ->
    @curregion = region

    color_scale = d3.scale.category10().domain(["teller", "loan", "office"])
    button = d3.select(@parent).selectAll("button").data(["teller", "loan", "office"])
    .enter().append('button').attr("type", "button").attr(
      class: "btn btn-xs"
      id: (d) -> d
    ).style('background-color', (d) -> color_scale(d)).text((d) -> d)

    # TODO: Toggle the active and inactive state for the button
    button.on("click", (d) =>
      if d not in @policystatus
        @policystatus.push(d)
      else
        @policystatus = @policystatus.filter( (val) => d != val )
      @draw(@curregion))

    data = @allbudata.filter( (d) => d.businessunit == region)

    d3.select(@parent).selectAll("svg").remove()
    canvas = d3.select(@parent).append('svg').attr(
      width : @width + @margin.left + @margin.right,
      height : @height + @margin.top + @margin.bottom
    )
    svg = canvas.append('g').attr("transform","translate("+@margin.left + ","+@margin.top+")")

    x = d3.time.scale().range([0,@width])
    x.domain(d3.extent(data, (d) -> d.timestamp))

    y = d3.scale.linear().range([@height,0])
    y.domain([d3.min(data, (d) => d3.min((+d["#{s}_avg_conn"] for s in @policystatus))),
              d3.max(data, (d) => d3.max((+d["#{s}_avg_conn"] for s in @policystatus)))])

    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")

    color_scale = d3.scale.category10().domain(["teller", "loan", "office"])

    @policystatus.forEach( (policystatus) =>

      svg.append("path").datum(data).attr("class", "line").attr(
        d : d3.svg.line().x( (d) -> x(d.timestamp)).y((d) => y(+d["#{policystatus}_avg_conn"]))
        stroke: color_scale(policystatus)
      )
    )

    svg.append('rect').attr(
      class: 'overlay'
      width: @width + @margin.left + @margin.right
      height: @height + @margin.top + @margin.bottom
      fill: 'none'
      'pointer-events': 'all'
    )
    svg.on("mousemove", () =>
      x0 = x.invert(d3.mouse(d3.event.target)[0])
      bisectDate = d3.bisector((d) -> d.timestamp).left
      i = bisectDate(data, x0, 1)
      d0 = data[i-1]
      d1 = data[i]
      d = if x0 - d0.date > d1.date - x0 then  d1 else d0
      data_list = data.filter((d) -> d.timestamp == d0.timestamp)
      svg.select('#ws_conn_tooltip_line').remove()
      svg.append('line').attr(
        x1: x(d.timestamp)
        y1: 0
        x2: x(d.timestamp)
        y2: @height
        stroke: 'green'
        'stroke-width' : 2
        id: 'ws_conn_tooltip_line'
      )
      svg.select('#ws_conn_data_id').remove()

      tootltip_box = svg.append('g').attr('id', 'ws_conn_data_id')
      tootltip_box.append('text').text(d['healthtime']).attr('x', x(d.timestamp)+10).attr('y', 30).attr('stroke', 'green').attr('stroke-width',0.5)
      num_policy_in_text = 1
      @policystatus.forEach( (policystatus) =>
        tootltip_box.append('text').text("#{policystatus}: #{d[policystatus+'_avg_conn']}").attr('x', x(d.timestamp)+10).attr('y', 30+num_policy_in_text*10)
        .attr('stroke', 'green').attr('stroke-width',0.5)
        num_policy_in_text = num_policy_in_text + 1
      )
    )

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
    .text("Average Connections")
