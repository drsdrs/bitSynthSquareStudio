window.inits[100] =
  desc: "imprtant stuff10"
  init:()-> #initd3()





cmos =
  "divider":
    inputs: [
      "clock", "clear"
    ]
    outputs:[]
    states:
      clock:0
      data:0
    gen:()-> null

sc = # Synthesizer config


initd3 = ->
  c.l "initd3"


  links = [
    {source: "Microsoft", target: "Amazon", type: "licensing"},
    {source: "Amazon", target: "Samsung", type: "licensing"},
    {source: "Samsung", target: "Motorola", type: "suit"},
    {source: "Motorola", target: "Apple", type: "suit"},
    {source: "Apple", target: "HTC", type: "resolved"},
    {source: "HTC", target: "Apple", type: "suit"},
    {source: "Kodak", target: "Apple", type: "suit"},
  ]

  nodes = {}
  # Compute the distinct nodes from the links.
  # Use elliptical arc path segments to doubly-encode directionality.

  tick = ->
    path.attr 'd', linkArc
    rect.attr 'transform', transform
    text.attr 'transform', transform

  linkArc = (d) ->
    dx = d.target.x - (d.source.x)
    dy = d.target.y - (d.source.y)
    dr = Math.sqrt(dx * dx + dy * dy)
    'M' + d.source.x + ',' + d.source.y + 'A' + dr + ',' + dr + ' 0 0,1 ' + d.target.x + ',' + d.target.y

  transform = (d) ->
    'translate(' + d.x + ',' + d.y + ')'

  links.forEach (link) ->
    link.source = nodes[link.source] or (nodes[link.source] = name: link.source)
    link.target = nodes[link.target] or (nodes[link.target] = name: link.target)

  width = 960
  height = 500

  force = d3.layout.force().nodes(d3.values(nodes))
    .links(links).size([
      width
      height
    ])
    .linkDistance(160)
    .charge(-30)
    .on('tick', tick)
    .start()

  svg = d3.select('body').append('svg').attr('width', width).attr('height', height)

  path = svg.append('g').selectAll('path')
    .data(force.links())
    .enter()
    .append('path')
    .attr('class', (d) -> 'link ' + d.type)
    .attr('marker-end', (d) -> 'url(#' + d.type + ')'  )

  rect = svg.append('g').selectAll('rect').data(force.nodes())
    .enter()
    .append('rect')
    .attr('stroke-width', 1)
    .attr('stroke', "#f00")
    .attr('fill', "#aaa")
    .attr('width', 64)
    .attr('height', 64)
    .call(force.drag)
    .on("click", ->c.l "sad")

  text = svg.append('g').selectAll('text').data(force.nodes())
    .enter()
    .append('text')
    .attr('x', 8)
    .attr('y', '.31em')
    .text((d) -> d.name)
