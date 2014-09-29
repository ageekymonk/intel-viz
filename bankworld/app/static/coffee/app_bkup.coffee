
$("#region").selectmenu()
$("#branch").selectmenu()
$('#machineclass').buttonset()
$( "#slider-range" ).slider(
  range: true,
  min: 0,
  max: 500,
  values: [75,300],
  slide: (event, ui) ->
    console.log(ui.values[0])

)

class Margin
  constructor: (args...)->
    @top = 0
    @right = 0
    @bottom = 0
    @left = 0
    @width = 0
    @height = 0

    if args.length is 1
      @top = @right = @bottom = @left = args[0]
    else if args.length is 2
      @top = @bottom = args[0]
      @right = @left = args[1]
    else if args.length is 3
      @top = args[0]
      @bottom = args[2]
      @right = @left = args[1]
    else if args.length is 4
      [@top, @right, @bottom, @left] = args

    @width = @right + @left
    @height = @top + @bottom
  toString: ()->
    return [@top, @right, @bottom, @left].map((d)-> "#{d}px").join(" ")

class HeatMap
  #
  # ### constructor
  #
  #
  # * @param  target String 	XPath for the elememt
  # * @param  opt    Object		option
  #
  constructor: (target, @opt = {})->
    @target = d3.select(target)
    @margin = @opt.margin or new Margin(100)
    @width  = @opt.width or @margin.width
    @height = @opt.height or @margin.height

    console.log(@width)
    console.log(@height)
    @table = @target.append('div')
    .attr(
      width: @width + @margin.width
      height: @height + @margin.height)
    .append('table').attr(
      width: @width
      height: @height).style('margin', "#{@margin}")
    @draw_done = 0
  #
  # ### draw
  #
  # Drawning method
  #
  # * @param data -> a json data
  #
  draw: (data) ->
    if @draw_done != 0
      @appendCols(data)
      return
    @draw_done = 1
    [rnum, cnum] = [data.length + 1, 1 + d3.max(data, (d) -> d.cols.length) ]

    # calculate the cell height and width
    cellSize =
      height: @height / rnum
      width:  @width  / cnum

    # for displaying the ratio
    if @opt.ratio
      rsum = data.map (d)-> d3.sum d.cols[0...cnum], (dd)-> +dd.value
      color = d3.scale.linear().domain([0, 1]).range(['white', 'red'])
      percent = d3.format('.1%')
    else
      # for not-displaing ratio
      max = d3.max(data, (d)-> d3.max(d.cols[0...cnum], (dd)-> +dd.value))
      color = d3.scale.linear().domain([0, max]).range(['white', 'red'])

    # add the header row
    headerRow = @table.append('tr')
    headerData = [""].concat (col.name for col in data[0].cols)
    console.log(headerData)
    headerCell = headerRow.selectAll('th').data(headerData).enter()
    .append('th').text((d)-> d).attr('width', cellSize.width)
    .style('border', '1px solid grey')
    console.log(new Date())
    # add data.
    data.forEach (rowDat, rid)=>
      row = @table.append('tr').attr('height', cellSize.height)
      coldata = [data[rid].value].concat (col.value for col in data[rid].cols)

      cell = row.selectAll('td').data(coldata).enter().append('td')
      .style('border', '1px solid grey').style('text-align', 'center')

      if @opt.ratio
        cell.style('background', (d, idx)-> if idx > 0 then color(d / rsum[rid]) else "#EFEFEF")
        cell.text((d, idx)-> if idx is 0 then d else percent(d / rsum[rid]))
      else
        cell.style('background', (d, idx)-> if idx > 0 then color(d) else "#EFEFEF")
        cell.text((d, idx)-> d)
    console.log(new Date())

  appendCols: (data) ->
    [rnum, cnum] = [data.length + 1, 1 + d3.max(data, (d) -> d.cols.length) ]

    # calculate the cell height and width
    cellSize =
      height: @height / rnum
      width:  @width  / cnum

    # for displaying the ratio
    if @opt.ratio
      rsum = data.map (d)-> d3.sum d.cols[0...cnum], (dd)-> +dd.value
      color = d3.scale.linear().domain([0, 1]).range(['white', 'red'])
      percent = d3.format('.1%')
    else
      # for not-displaing ratio
      max = d3.max(data, (d)-> d3.max(d.cols[0...cnum], (dd)-> +dd.value))
      console.log(max)
      color = d3.scale.linear().domain([0, max]).range(['white', 'red'])

    # add the header row
    headerRow = @table.select('tr').selectAll('th').filter( (d) -> 0 ).data((col.name for col in data[0].cols)).enter()
    .append('th').text((d)-> d).attr('width', cellSize.width)
    .style('border', '1px solid grey')
    # add data.
    data.forEach (rowDat, rid)=>
      coldata = (col.value for col in data[rid].cols)
      rid_for_select = rid + 2
      row = @table.select("tr:nth-child(#{ rid_for_select })")
      cell = row.selectAll('td').filter( (d) -> 0 ).data(coldata).enter().append('td')
      .style('border', '1px solid grey').style('text-align', 'center')

      if @opt.ratio
        cell.style('background', (d, idx)-> if idx > 0 then color(d / rsum[rid]) else "#EFEFEF")
        cell.text((d, idx)-> if idx is 0 then d else percent(d / rsum[rid]))
      else
        cell.style('background', (d, idx)-> if idx >= 0 then color(d) else "#EFEFEF")
        cell.text((d, idx)-> d)
    console.log(new Date())


  remove: (colid) ->
    console.log("here")


myheatmap = new HeatMap('body')
#myheatmap.draw(heatdata)
#
#$.getJSON('http://localhost:5000/region', {region : '1', policystatus: 5}, (data) =>
#  myheatmap.draw(data.result)
#)
#
#$.getJSON('http://localhost:5000/region', {region : '1', policystatus: 4}, (data) =>
#  myheatmap.appendCols(data.result)
#)
#
#$.getJSON('http://localhost:5000/region', {region : '1', policystatus: 3}, (data) =>
#  myheatmap.appendCols(data.result)
#)
#
#$.getJSON('http://localhost:5000/region', {region : '1', policystatus: 2}, (data) =>
#  myheatmap.appendCols(data.result)
#)

$("#bwdashform").submit( (event) =>
  postdata = $("#bwdashform").serialize()
  console.log(postdata)
  $.getJSON('http://localhost:5000/region', postdata, (data) =>
#    myheatmap.draw(data.result)
  )
  event.preventDefault()
)
