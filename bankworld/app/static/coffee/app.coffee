#'use strict'
#
#$("#region").selectmenu()
#$("#branch").selectmenu()
#$('#machineclass').buttonset()
#$( "#slider-range" ).slider(
#  range: true,
#  min: 0,
#  max: 500,
#  values: [75,300],
#  slide: (event, ui) ->
#    console.log(ui.values[0])
#
#)
#
#class Dashboard
#  constructor: ->
#    @policyTimeChart = dc.lineChart("#policy-time-chart", "policy")
#    @activityTimeChart = dc.lineChart("#activity-time-chart", "activity")
#    @mcfilterlist = []
#    @submit = false
#  setcallback: ->
#    $("#bwdashform").submit( (event) =>
#      postdata = $("#bwdashform").serialize()
#      console.log(postdata)
#
#      if @submit then return
#
#      event.preventDefault()
#      @submit = true
#
#      d3.csv("http://localhost:5000/regionactivity?" + postdata).get((error,data) =>
#        @plotActivityData(data)
#      )
#
#      d3.csv("http://localhost:5000/regionpolicy?" + postdata).get((error,data) =>
#        @plotPolicyData(data)
#      )
#
#    )
#
#    $(".machineclass").change( =>
#
#      flist = $(".machineclass").map( (idx,elem) -> elem.id if elem.checked)
#      console.log(flist)
#      if @policyServerDimension
#        @policyServerDimension.filterAll()
#        if flist.length != 0 then @policyServerDimension.filter( (d) => d in flist)
#
#      if @activityServerDimension
#        @activityServerDimension.filterAll()
#        if flist.length != 0 then @activityServerDimension.filter( (d) => d in flist)
#
#      dc.redrawAll("policy")
#      dc.redrawAll("activity")
#    )
#    $(".machinefunction").change( =>
#
#      flist = $(".machinefunction").map( (idx,elem) -> elem.id if elem.checked)
#      console.log(flist)
#      if @policyServerFnDimension
#        @policyServerFnDimension.filterAll()
#        if flist.length != 0 then @policyServerFnDimension.filter( (d) => d in flist)
#
#      if @activityServerFnDimension
#        @activityServerFnDimension.filterAll()
#        if flist.length != 0 then @activityServerFnDimension.filter( (d) => d in flist)
#
#      dc.redrawAll("policy")
#      dc.redrawAll("activity")
#    )
#
#  plotActivityData: (data) ->
#    dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
#
#    data.forEach( (d) ->
#      d.timestamp = dateFormat.parse(d.healthtime)
#    )
#
#    @activityCf = crossfilter(data)
#
#    timedimension = @activityCf.dimension( (d) -> d.timestamp )
#    timedimensiongroup = timedimension.group().reduceSum( (d) -> +d.ipaddrcount )
#
#    @activityServerDimension = @activityCf.dimension( (d) -> d.machineclass)
#    @activityServerFnDimension = @activityCf.dimension( (d) -> d.machinefunction)
#
#    #    serverDimension.filter("atm")
#    minDate = timedimension.bottom(1)[0].timestamp
#    maxDate = timedimension.top(1)[0].timestamp
#
#    @activityTimeChart.width(820)
#    .height(280).dimension(timedimension)
#    .group(timedimensiongroup)
#    .x(d3.time.scale().domain([dateFormat.parse('2012-02-02 08:00:00'), dateFormat.parse('2012-02-04 08:30:00')]))
#    .mouseZoomable(true)
#    .brushOn(false)
#    .elasticX(false)
#    .elasticY(true)
#
#    @setcallback()
#    dc.renderAll("activity")
#
#  plotPolicyData: (data) ->
#    dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
#
#    data.forEach( (d) ->
#      d.timestamp = dateFormat.parse(d.healthtime)
#    )
#
#    @policycf = crossfilter(data)
#
#    timedimension = @policycf.dimension( (d) -> d.timestamp )
#    timedimensiongroup = timedimension.group().reduceSum( (d) -> +d.ipaddrcount )
#
#    @policyServerDimension = @policycf.dimension( (d) -> d.machineclass)
#    @policyServerFnDimension = @policycf.dimension( (d) -> d.machinefunction)
#    minDate = timedimension.bottom(1)[0].timestamp
#    maxDate = timedimension.top(1)[0].timestamp;
#
#    @policyTimeChart.width(820)
#    .height(280)
#    .dimension(timedimension)
#    .group(timedimensiongroup)
#    .x(d3.time.scale().domain([dateFormat.parse('2012-02-02 08:00:00'), dateFormat.parse('2012-02-04 08:30:00')]))
#    .mouseZoomable(true)
#    .brushOn(false)
##    .xaxis().scale([dateFormat.parse('2012-02-02 06:00:00'), dateFormat.parse('2012-02-04 06:00:00')])
#    .elasticX(false)
#    .elasticY(true)
#
#    @setcallback()
#    dc.renderAll("policy")
#    @submit = false
#
#
#
#mydashboard = new Dashboard()
#mydashboard.setcallback()
#
#
#
#
#
