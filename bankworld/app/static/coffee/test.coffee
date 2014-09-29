#class ZoomBubblePlot
#  constructor: (@width=1280, @height=800, @radius=720) ->
#    @svg = d3.select('body').append('svg').attr(width : @width, height : @height)
#    @xrange = d3.scale.linear().range([0,@radius])
#    @yrange = d3.scale.linear().range([0,@radius])
#    @pack = d3.layout.pack().size([@radius, @radius]).value( (d) -> d.size)
#    @node = 0
#
#  zoom: (d,i) =>
#    k = @radius / d.r / 2;
#    @xrange.domain([d.x - d.r, d.x + d.r]);
#    @yrange.domain([d.y - d.r, d.y + d.r]);
#
#    #t = @svg.transition().duration(d3.event.altKey ? 7500 : 750);
#    t = @svg
#    t.selectAll("circle").attr(
#      cx: (d) =>
#        @xrange(d.x)
#      cy: (d) => @yrange(d.y)
#      r: (d) -> k * d.r)
#
#    @node = d;
#    d3.event.stopPropagation();
#
#  plot: ->
##    $.getJSON('http://localhost:5000/businessunit', {}, (data) =>
#    d3.json('http://localhost:5000/businessunit', (data) =>
#      root = data.result
#      @node = data.result
#      nodes = @pack.nodes(root)
#      @svg.selectAll('circle').data(nodes).enter().append('circle')
#      .attr(
#        class: (d) -> d.children ? 'parent' : 'child'
#        cx: (d) ->
#          console.log(d.x)
#          d.x
#        cy: (d) -> d.y
#        r: (d) -> d.r
#        fill: 'none'
#      ).on('click', (d) => @zoom(if @node == d then root else d))
#      d3.select(window).on('click', () => @zoom(root))
#    )
#
#a = new ZoomBubblePlot()
#a.plot()