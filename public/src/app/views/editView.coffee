define [
  "lib/d3"
  "cs!app/synth"
], (d3, synth)->

  h = window.innerHeight/2
  w = window.innerWidth

  margin =
    top: 10
    left: 35
    right: 25
    bottom: 25

  synth = null
  svg = null
  svgG = null


  init = (activeSynth)->
    d3.select('#editView svg').remove()
    svg = d3.select('#editView').append('svg').attr('height', h).attr('width', w)
    svgG =  svg.append('svg:g')
      .attr("width", w-(margin.left+margin.right) )
      .attr("height", h-(margin.top+margin.bottom) )
      .attr("transform", "translate(" + margin.left + "," + (h-margin.bottom) + ")")

      
    synth = activeSynth
    initEnv synth[0].envelopes[0]

  initEnv = (env)->
    x = d3.scale.linear()
      .domain([0,env.length])
      .range([margin.left, w-margin.left])

    xAxis = d3.svg.axis().scale(x).orient("bottom")
      .ticks(10)
      .tickFormat(d3.format("s"))


    y = d3.scale.linear().domain([env.max, env.min]).range([margin.top, h-margin.bottom])
    yAxis = d3.svg.axis().scale(y).orient("left")

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(" + 0 + "," + (h-margin.bottom) + ")")
      .call(xAxis)

    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + margin.left + "," + (0) + ")")
      .call(yAxis)
    draw env

  draw = (env)->
    data = env.data
    links = svgG.selectAll("line").data(env.data)
    ww = w-(margin.left+margin.right)
    hh = h-(margin.top+margin.bottom)

    #links = links.enter()
    links.enter().append('line')
      .attr("x1", (d)-> d.time/env.length*ww )
      .attr("y1", (d)-> d.value/(env.min-env.max)*hh )
      .attr("x2", (d, i)->
        time = if i-1<0 then d.time else data[i-1].time
        time/env.length*ww
      )
      .attr("y2", (d,i)->
        value = if i-1<0 then d.value else data[i-1].value
        value/(env.min-env.max)*hh
      )


    links.enter().append('circle')
      .attr("r", 10)
      .attr("cx", (d, i)-> ww/env.length*d.time )
      .attr("cy", (d, i)-> -hh/env.max*d.value )
      .attr("class", "connector")
      .on "click", null

    links.exit().remove()


  returnFunctions =
    draw: draw
    init: init
