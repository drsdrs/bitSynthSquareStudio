define [
  "lib/d3"
  "cs!app/synth"
], (d3, synth)->

  nodes = []
  links = []
  parts = []
  force = null
  nodesData = null
  h = window.innerHeight/2
  w = window.innerWidth

  svg = d3.select('#synthView').append('svg').attr('height', h).attr('width', w)
  nodesData =  svg.append('svg:g').selectAll('g')
  edges =  svg.append('svg:g').selectAll('path')
  
  color = d3.scale.category20()

  bw = w/15
  bh = h/15
  r = 16

  sourceNode = null
  
  svg.append('svg:defs').selectAll('marker').data([ 'end' ])
    .enter().append('svg:marker').attr('id', String)
    .attr('viewBox', '0 -5 10 10').attr('refX', 15.5)
    .attr('refY', 0).attr('markerWidth', 14)
    .attr('markerHeight', 6).attr('orient', 'auto')
    .append('svg:path')
    .attr 'd', 'M0,-5 L10,0 L0,5 L0,-5'

  dragPath = svg.append('svg:g').append("path")
    .attr("class", "link")
    .attr('marker-end', 'url(#end)')

  class Node
    constructor: (fixed, data, pos)->
      @data = data
      @fixed = fixed
      @.data.pos = pos
      @x = if data.type=="master" then (w/2)-bw/2 else w*Math.random()
      if data.type=="master" then @y = h-bh*2
      else if data.type=="generator" then @y = bh
      else @y = h*Math.random()


  addNode = (part)->
    fixed = if part.type=="master"||part.type=="generator" then 1 else 0
    nodes.push new Node fixed, part, nodes.length
    
  addLink = (src, trg)->
    links.push "source": src.pos, "target": trg.pos
    
  genNodesLinks = (partsNew)->
    nodes = []
    links = []
    parts = partsNew
    checkInfinite()
    genNodes()
    genLinks()
    startForce()

  genNodes = -> parts.forEach (sp,i)-> addNode sp
  genLinks = ->
    nodes.forEach (sp)->
      addLinkInputs = (part)->
        if part.input?
          addLink part.input, part
          addLinkInputs part.input
        else if part.inputs?
          part.inputs.forEach (input)->
            addLink input, part
            addLinkInputs input

      if sp.data.type=="master" then addLinkInputs sp.data


  connectNode = (e)->
    if !sourceNode?
      d3.select(@).classed("connect", true)
      sourceNode = e
    else if (sourceNode.data.outputs? && e.data.inputs?)&&sourceNode!=e # check if connectable
      ## TODO check for inifinite loop=
      dragPath.attr("d", "M0,0")
      multipleConnections = e.data.type!="master"&&e.data.type!="mixer"&&e.data.inputs.length>=1
      inputClone = e.data.inputs.some (input)-> return true if input==sourceNode.data
      return sourceNode = null if multipleConnections || inputClone
      sourceNode.data.outputs.push e.data
      e.data.addInput sourceNode.data
      sourceNode = null
      checkInfinite()
      genLinks()
      draw()
      d3.select(".connect").classed("connect", false)

  checkInfinite = ()->

    return null
    startTrace = (part)->
      checkInputs = (part, partOld, visited)->
        visited = visited||{}
        if visited[part.id]?
          #partOld.inputs.forEach (outOld, i)->
            #if outOld==part then c.l "cutout", partOld.outputs.splice i,1
          return c.l "No loop allowed", part.type, partOld.type
        return c.l "no more outs" unless part.input?&&part.inputs?
        visited[part.id] = part.type

        part.outputs.forEach (output, oi)->
          checkOutputs output, part, visited
      checkInputs part

    parts.forEach (part)-> if part.type=="master" then startTrace part

  checkInfiniteOld = ()->
    startTrace = (part)->
      visArr = []
      checkOutputs = (part, partOld, visited)->
        visited = visited||{}
        if visited[part.id]?
          partOld.outputs.forEach (outOld, i)->
            if outOld==part then c.l partOld.outputs.splice i,1
          return c.l "No loop allowed", part.type, partOld.type
        return c.l "no more outs" unless part.outputs?
        visited[part.id] = part.type
        visArr.push part
        part.outputs.forEach (output, oi)->
          checkOutputs output, part, visited

      checkOutputs part

    parts.forEach (part)->
      if part.type=="generator"
        part.outputs.forEach (part)-> startTrace part


  draw = ->
    ### Draw the edges/links between the nodes ###
    edges = edges.data(links)
    edges.enter()
      .append('path')
      .attr("class", "link")
      .attr('marker-end', 'url(#end)')

    ### Draw the nodes themselves ###
    nodesData = nodesData.data(nodes)

    gnodes = nodesData.enter().append('g').call(force.drag)
    gnodes.append('line')
      .attr("x1", 0)
      .attr("y1", 0)
      .attr("x2", 0)
      .attr("y2", bh)
    gnodes.append('rect')
      .attr("x", -bw/2)
      .attr("y", bh)
      .attr('width', bw).attr('height', bh)
      .style('fill', (d, ni) -> color ni)
    gnodes.append('text')
      .attr('transform', 'translate('+(-(bw/2))+', '+(bh*1.8)+')')
      .attr('fill', 'black')
      .text((d) -> d.data.type )
    gnodes.append('circle')
      .attr("r", r)
      .attr("class", "connector")
      .on "click", connectNode

    edges.exit().remove()
    nodesData.exit().remove()
    force.start()

  startForce = ->
    force = d3.layout.force()
      .nodes(nodes).links(links)
      .size([ w, h])
      .linkDistance([120])
      .friction([0.8])
      .charge([ -300 ]).gravity(0.4)
      .start()

    force.on 'tick', ->
      edges.attr 'd', (d) ->
        x1 = d.source.x
        y1 = d.source.y
        x2 = d.target.x
        y2 = d.target.y

        'M' + x1 + ',' + y1 + ' L' + x2 + ',' + y2# + ' ' + xRotation + ',' + largeArc + ',' + sweep + ' ' + x2 + ',' + y2
      nodesData.attr('transform', (d) -> 'translate(' + d.x + ',' + d.y + ')')

  svg.on "mousemove", (e)->
    return unless sourceNode?
    pos = d3.mouse(this)
    dragPath.attr 'd', (d) ->
      x1 = sourceNode.x
      y1 = sourceNode.y
      x2 = pos[0]-2
      y2 = pos[1]-2

      'M' + x1 + ',' + y1 + ' L' + x2 + ',' + y2

  returnFunctions =
    addNode: addNode
    draw: draw
    genNodesLinks: genNodesLinks
    checkInfinite: checkInfinite