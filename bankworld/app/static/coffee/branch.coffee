#class Dashboard
#  constructor: ->
#    @policyTimeChart = dc.lineChart("#policy-time-chart", "policy")
#    @policyTimeChart.turnOnControls(true)
#    @branchPieChart = dc.pieChart("#branch-policy-chart", "policy")
#    @branchPieChart.turnOffControls(true)
#    @policyChart = dc.lineChart("#policy-chart", "policy")
#    @policyChart.turnOnControls(true)
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
#    timedimension1 = @policycf.dimension( (d) -> d.timestamp )
#    branchdimension = @policycf.dimension( (d) -> d.businessunit )
#    branchdimensiongroup = branchdimension.group().reduceSum( (d) -> +d.ipaddrcount )
#
#    timedimensiongroup = timedimension.group().reduceSum( (d) -> +d.ipaddrcount )
#    policydimension = @policycf.dimension ( (d) -> d.policystatus )
#
#    policy3group = timedimension1.group().reduceSum( (d) -> if +d.policystatus == 3 then +d.ipaddrcount else 0)
#    policy4group = timedimension1.group().reduceSum( (d) -> if +d.policystatus == 4 then +d.ipaddrcount else 0)
#    policy5group = timedimension1.group().reduceSum( (d) -> if +d.policystatus == 5 then +d.ipaddrcount else 0)
#
#    @policystatusDimension = @policycf.dimension( (d) -> d.policystatus)
#    minDate = timedimension.bottom(1)[0].timestamp
#    maxDate = timedimension.top(1)[0].timestamp;
#    timedimension.filterRange([minDate,maxDate])
#    @policyTimeChart.width(820)
#    .height(180)
#    .dimension(timedimension)
#    .group(policy5group, "Policy 5")
#    .stack(policy4group, "Policy 4")
#    .stack(policy3group, "Policy 3")
#    .renderArea(true)
#    .x(d3.time.scale().domain([minDate, maxDate]))
#    .mouseZoomable(true)
#    .brushOn(true)
#    .elasticY(true)
#    .elasticX(true)
#    .legend(dc.legend().x(50).y(10).itemHeight(13).gap(5))
#    .margins({top: 20, left: 50, right: 10, bottom: 20})
#
#    @policyChart.width(820)
#    .height(180)
#    .dimension(timedimension1)
#    .group(policy5group, "Policy 5")
#    .stack(policy4group, "Policy 4")
#    .stack(policy3group, "Policy 3")
#    .rangeChart(@policyTimeChart)
#    .renderArea(true)
#    .x(d3.time.scale().domain([minDate, maxDate]))
#    .mouseZoomable(true)
#    .brushOn(true)
#    .elasticY(true)
#    .elasticX(true)
#    .legend(dc.legend().x(50).y(10).itemHeight(13).gap(5))
#    .margins({top: 20, left: 50, right: 10, bottom: 20})
#
#
#    @branchPieChart
#    .width(150).height(150)
#    .dimension(branchdimension)
#    .group(branchdimensiongroup)
#    .innerRadius(30);
#
#    dc.renderAll("policy")
#
#
#
#mydashboard = new Dashboard()
#
#d3.csv('/static/csv/policy5_allbranch.csv',(data) =>
#  mydashboard.plotPolicyData(data)
#)