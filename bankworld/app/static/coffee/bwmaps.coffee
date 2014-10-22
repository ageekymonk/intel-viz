'use strict'

class BWMap
  constructor: (width=400, height=300, parent="body",evDispatch) ->
    @width = width
    @height = height
    @parent = parent
    @evDispatch = evDispatch
    @projection = d3.geo.equirectangular()
    @svg = d3.select(parent).append("svg").attr(
      width: @width
      height: @height
    )
    @coord = null
    @datareport = null
  load: ->
    d3.csv('/static/csv/branch_lat_long.csv').get((error, world) =>
      world.forEach( (d) =>
        [d.x1,d.y1] = @projection([d.minlong,d.maxlat])
        [d.x2,d.y2] = @projection([d.maxlong,d.minlat])

        d.width =  if (d.x2 - d.x1) == 0 then 5 else (d.x2 - d.x1)
        d.height = if (d.y2 - d.y1) == 0 then 5 else (d.y2 - d.y1)
      )
      dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
      @coord = world
      d3.csv('/static/csv/ws_report_status.csv').get((error,datareport) =>
        @datareport = datareport
        datareport.forEach((d) ->
          dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
          d.timestamp = dateFormat.parse(d.healthtime)
        )
        @evDispatch.attime(dateFormat.parse("2012-02-02 14:00:00"))
      )
    )

  draw: (time)->
    @svg.remove()
    @svg = d3.select(@parent).append("svg").attr(
      width: @width
      height: @height
    )
    @svg.append("svg:image")
            .attr("xlink:href", "/static/images/BankWorld-binary.png")
            .attr("x", "0")
            .attr("y", "0")
            .attr("width", @width)
            .attr("height", @height);

    @svg.insert("path", ".graticule")
            .attr("class", "boundary")
            .attr("d", "").attr('fill', "url(#img1)")

#    @svg.selectAll(".area").data(@coord)
#    .enter().append("rect", ".area")
#    .attr(
#      x: (d) -> d.x1 + d.width/2
#      y: (d) -> d.y1 + d.height/2
#      width: (d) -> 0
#      height: (d) -> 0
#      id: (d) -> "bu_"+d.businessunit
#      visible: false
#    ).style("stroke", "blue").attr("fill", "white").on("click", (d) =>
#      @evDispatch.selectRegion(d.businessunit))

    @svg.selectAll(".area").data(@coord)
    .enter().append("circle", ".area")
    .attr(
      cx: (d) -> d.x1
      cy: (d) -> d.y1
      r: (d) -> 0
      id: (d) -> "bu_"+d.businessunit
    ).style("stroke", "black").attr(
      "fill" : "red"
      "fill-opacity": .8
    ).on("click", (d) =>
      @evDispatch.selectRegion(d.businessunit))

    @svg.selectAll('circle').on("mouseover.tooltip",
    (d) =>
      @svg.select('#data_id').remove()
      @svg.append('text').text(d.businessunit).attr('x', d.x1).attr('y', d.y1).attr('id', 'data_id')
    )
    @svg.selectAll('circle').on("mouseout.tooltip",
    (d) => @svg.select('#data_id').transition().duration(20).style('opacity',0).attr('transform','translate(10,-10)').remove())

    report = @datareport.filter((d) => +d.timestamp == +time)

    report.forEach( (d) =>
      if d.businessunit  == 'datacenter-5'
        console.log(d)
      if ((+d.expected - +d.reported) / +d.expected)*100 >= 10
        @svg.select("#bu_"+d.businessunit).attr(
          r:  ((+d.expected - +d.reported) / +d.expected)*10
        )
    )
#    report.forEach( (d) =>
#      if ((+d.expected - +d.reported) / +d.expected)*100 >= 10
#        @svg.select("#bu_"+d.businessunit).attr(
#          r: (x) -> ((+d.expected - +d.reported) / +d.expected)*10
#        )
#    )
#    report.forEach( (d) =>
#      @svg.select("#bu_virus_"+d.businessunit).attr(
#        r : (x) -> 3+(+d.numipaddr/40))
#    )


    d3.select(self.frameElement).style("height", @height + "px")



class BWMapVirus
  constructor: (width=400, height=300, parent="body",evDispatch) ->
    @width = width
    @height = height
    @parent = parent
    @evDispatch = evDispatch
    @projection = d3.geo.equirectangular()
    @svg = d3.select(parent).append("svg").attr(
      width: @width
      height: @height
    )
    @coord = null
    @datareport = null
  load: ->
    d3.csv('/static/csv/branch_lat_long.csv').get((error, world) =>
      world.forEach( (d) =>
        [d.x1,d.y1] = @projection([d.minlong,d.maxlat])
        [d.x2,d.y2] = @projection([d.maxlong,d.minlat])

        d.width =  if (d.x2 - d.x1) == 0 then 5 else (d.x2 - d.x1)
        d.height = if (d.y2 - d.y1) == 0 then 5 else (d.y2 - d.y1)
      )
      dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
      @coord = world
      d3.csv('/static/csv/policy5_status.csv').get((error,datareport) =>
        @datareport = datareport
        datareport.forEach((d) ->
          dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
          d.timestamp = dateFormat.parse(d.healthtime)
        )
        @evDispatch.attime(dateFormat.parse("2012-02-02 14:00:00"))
      )
    )

  draw: (time)->

    @svg.remove()
    @svg = d3.select(@parent).append("svg").attr(
      width: @width
      height: @height
    )
    @svg.append("svg:image")
    .attr("xlink:href", "/static/images/BankWorld-binary.png")
    .attr("x", "0")
    .attr("y", "0")
    .attr("width", @width)
    .attr("height", @height);

    @svg.insert("path", ".graticule")
    .attr("class", "boundary")
    .attr("d", "").attr('fill', "url(#img1)")

    @svg.selectAll(".area").data(@coord)
    .enter().append("circle", ".area")
    .attr(
      cx: (d) -> d.x1
      cy: (d) -> d.y1
      r: (d) -> 0
      id: (d) -> "bu_virus_"+d.businessunit
    ).style("stroke", "black").attr(
        "fill" : "red"
        "fill-opacity": .8
    ).on("click", (d) =>
        $('#myModal').modal()
        @evDispatch.selectRegion(d.businessunit))


    @svg.selectAll('circle').on("mouseover.tooltip",
      (d) =>
        @svg.select('#spread_data_id').remove()
        @svg.append('text').text(d.businessunit).attr('x', d.x1).attr('y', d.y1+10).attr('id', 'spread_data_id').attr(
          stroke : 'blue'
          'stroke-width': '0.5'
        )
    )
    @svg.selectAll('circle').on("mouseout.tooltip",
    (d) => @svg.select('#spread_data_id').transition().duration(20).style('opacity',0).attr('transform','translate(10,-10)').remove())

    report = @datareport.filter((d) => +d.timestamp == +time)

    report.forEach( (d) =>
      @svg.select("#bu_virus_"+d.businessunit).attr(
        r : (x) -> 3+(+d.numipaddr/40))
    )
    d3.select(self.frameElement).style("height", @height + "px")


class BWReportMap
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

      @svg.selectAll('rect').on("mouseover.tooltip",
      (d) =>
        @svg.select('#data_id').remove()
        @svg.append('text').text(d.businessunit).attr('x', d.x1).attr('y', d.y1).attr('id', 'data_id')
      )
      @svg.selectAll('rect').on("mouseout.tooltip",
      (d) => @svg.select('#data_id').transition().duration(20).style('opacity',0).attr('transform','translate(10,-10)').remove())


      d3.select(self.frameElement).style("height", @height + "px")
    )