# applyStyle = (el)-> for key,val of el.attrs then el.style[key]= val


# max = w:window.innerWidth, h:window.innerHeight
# activeOffset = x:0,y:0
# activeEl = null
# activeAttrs = {}

# dragActive = (e)->
#   if activeEl?
#     y = e.y-activeOffset.y
#     x = e.x-activeOffset.x
#     if y>max.y then y = max.y
#     if x>max.x then x = max.x
#     if y<0 then y = 0
#     if x<0 then x = 0
#     x = activeEl.posx = Math.round(x/activeEl.attrs.width)
#     y = activeEl.posy = Math.round(y/activeEl.attrs.height)
#     activeEl.infoEl.innerText = x+":"+y
#     activeEl.style.left = activeEl.x = x*activeEl.attrs.width
#     activeEl.style.top = activeEl.y = y*activeEl.attrs.height

# dragEnd = -> activeEl = null

# document.addEventListener "mousemove", dragActive, false
# document.addEventListener "touchmove", dragActive, false

# document.addEventListener "mouseup", dragEnd, false
# document.addEventListener "touchend", dragEnd, false


# generatorContructor= ()->
#   @init() if @init
#   @pos = mainGen.generators.length
#   @el = document.createElement("div")
#   @el.attrs = @attrs
#   @el.x = @el.y = @el.posx = @el.posy = 0
#   @el.classList.add "instrument"

#   # pseudo click field for dragging
#   dragField = document.createElement("div")
#   dragField.addEventListener "mousedown", @makeActive, false
#   dragField.addEventListener "touchstart", @makeActive, false
#   dragField.classList.add "dragField"
#   @el.appendChild dragField
  
#   # X and Y position infos Plus audioSumBtn & anotherFX
#   infoRow = document.createElement "div"
#   @el.infoEl = document.createElement("span")
#   @el.infoEl.innerHTML = null
#   # audio summing method
#   @adderEl = document.createElement("button")
#   @adderEl.innerHTML = @adderOptions[@adder]
#   # audio summing methodanotherFx
#   @muteEl = document.createElement("button")
#   @muteEl.addEventListener "click", null, false
#   @muteEl.innerHTML = "U"

#   infoRow.appendChild @muteEl
#   infoRow.appendChild @el.infoEl
#   infoRow.appendChild @adderEl

#   @muteEl.addEventListener "click", @changeMute, false
#   @adderEl.addEventListener "click", @changeAdder, false

#   @el.appendChild infoRow

#   # volume elements
#   volRow = document.createElement("div")
#   @volumeEl = document.createElement("span")
#   plusVolumeEl = document.createElement("button")
#   minusVolumeEl = document.createElement("button")
#   plusVolumeEl.innerHTML = "+"
#   minusVolumeEl.innerHTML = "-"
#   @volumeEl.innerText = @volume
#   volRow.appendChild minusVolumeEl
#   volRow.appendChild @volumeEl
#   volRow.appendChild plusVolumeEl

#   plusVolumeEl.addEventListener "click", @plusVolume, false
#   minusVolumeEl.addEventListener "click", @minusVolume, false

#   @el.appendChild volRow

#   # position elements
#   posRow = document.createElement("div")
#   @posInfoEl = document.createElement("span")
#   plusPosEl = document.createElement("button")
#   minusPosEl = document.createElement("button")
#   @posInfoEl.innerHTML = @pos
#   plusPosEl.innerHTML = "+"
#   minusPosEl.innerHTML = "-"
#   @el.posInfoEl = @posInfoEl

#   plusPosEl.addEventListener "click", @plusPos, false
#   minusPosEl.addEventListener "click", @minusPos, false

#   posRow.appendChild minusPosEl
#   posRow.appendChild @posInfoEl
#   posRow.appendChild plusPosEl

#   @el.appendChild posRow

#   # append elements and make active
#   applyStyle @el
#   document.getElementById("container").appendChild @el

#   activeEl = @el
#   activeOffset = x: @attrs.width/2, y: @attrs.height/2
#   @


# class Generator
#   constructor: -> generatorContructor
#   p: 0
#   volume: 6
#   mute: false
#   adder: 0
#   adderOptions: ["|","M","m","&","^","+","-","*","/"]
#   adders: [
#     (a,b)-> a|b
#     (a,b)-> (a+b)/2
#     (a,b)-> (a*b)>>8
#     (a,b)-> a&b
#     (a,b)-> a^b
#     (a,b)-> a+b
#     (a,b)-> a-b
#     (a,b)-> a*b
#     (a,b)-> a/cb
#   ]
#   attrs:
#     left: max.w/2
#     top: max.h/2
#     width: 48
#     height: 48
#     background: "grey"
#   changeAdder: =>
#     @adder += 1
#     @adder %= @adderOptions.length
#     @adderEl.innerHTML = @adderOptions[@adder]

#   plusVolume: (e)=> @volume++; @changeVolume()
#   minusVolume: (e)=> @volume--; @changeVolume()
#   changeVolume: =>
#     @volume = @volume&7
#     @volumeEl.innerText = @volume

#   plusPos: (e)=> @changePosition +1
#   minusPos: (e)=> @changePosition -1
#   changePosition: (posMod)=>
#     len = mainGen.generators.length-1
#     @pos += posMod
#     if @pos>len
#       @pos = 0
#       splicedTarget = len
#     else if @pos<0
#       @pos = len
#       splicedTarget = 0
#     else splicedTarget = @pos-posMod
#     c.l "----------------------\n"
#     c.l "Generators", mainGen.generators
#     spliced = mainGen.generators.splice(@pos, 1, @)[0]
#     c.l "spliced Gen:", spliced
#     mainGen.generators[splicedTarget] = spliced
#     mainGen.resortGenerators()
#     @posInfoEl.innerText = @pos

#   changeMute: =>
#     @mute = !@mute
#     @muteEl.innerHTML = if @mute then "X" else "O"

#   makeActive: (e)=>
#     activeEl = @el
#     activeOffset =
#       x: e.offsetX
#       y: e.offsetY

#   applyRest: (sampleOld, sample)->
#     sample = (sample/7)*@volume
#     @adders[@adder] sampleOld, sample
mainGenerator = null
dly = null
gen1 = null
window.inits[350] =
  desc: "Audiogenerator"
  init:()->
    initModels()

    addGenerator= (e)->
      if e.target.id?
        c.l "add", e.target.id.split("new")
        newPart = new synth.partClasses[e.target.id.split("new")[1] ]
        synth.parts.push newPart
        addNode newPart
        mainGenerator.findGenerators()

        draw()

    document.getElementById("newGenerator").addEventListener "click", addGenerator
    document.getElementById("newMixer").addEventListener "click", addGenerator
    document.getElementById("newDelay").addEventListener "click", addGenerator

    (->
      #type = e.target.id
      gen1 = new synth.partClasses.Generator
      gen2 = new synth.partClasses.Generator
      gen3 = new synth.partClasses.Generator
      gen4 = new synth.partClasses.Generator
      mix1 = new synth.partClasses.Mixer
      mix2 = new synth.partClasses.Mixer
      dly = new synth.partClasses.Delay
      mstr = new synth.partClasses.Master

      gen1.freq = 220
      gen2.freq = 110
      gen3.freq = 55

      gen1.outputs.push dly
      dly.addInput gen1

      #dly.outputs.push mstr
      #mstr.addInput dly
      # gen2.outputs.push mix1

      # mix1.addInput gen1
      # mix1.addInput gen2
      # #gen3.outputs.push mix1
      # #gen3.outputs.push mix2
      # mix1.outputs.push mstr

      # mstr.addInput mix1
      # #mix2.outputs.push mstr
      #gen4.outputs.push mstr

      #gen2.outputs.push mstr

      # dly.outputs.push mix1
      # dly.outputs.push mix2

      # mix1.outputs.push mix2

      # mix2.outputs.push mstr

      synth.parts.push gen1
      synth.parts.push gen2
      synth.parts.push gen3
      synth.parts.push gen4
      synth.parts.push mix1
      synth.parts.push dly
      synth.parts.push mix2
      synth.parts.push mstr

      # synth.parts.push new Delay
      # synth.parts.push new Generator

      window.mainGen = mainGenerator = new MainGenerator
      Pico.play mainGenerator.gen
      #manualRun(220)
    )()


document.body.addEventListener "mousemove", (e)->
  maxX = window.innerWidth
  x= e.clientX
  y= e.clientY
  ratio = x/maxX
  gen1.freq = x*3


class MainGenerator
  startGenerators:[]
  master : null
  nextBuffer: null
  processed: 0
  constructor: ->
    @findGenerators()
    @findMaster()
  findGenerators: ->
    synth.parts.forEach (part, i)=>
      @startGenerators.push part if part.type=="generator"
  findMaster: ->
    synth.parts.forEach (part, i)=> @master= part if part.type=="master"

  fillNextBuffer: (buffer, size)->
    i = 0 # buffer iterator
    s = 0 # sample value
    tt = 0 # global time for sequencing
    for data, pos in buffer[0]
      s =  @master.gen()
      s = (s/127)-1
      s *= 0.5
      buffer[0][pos] = buffer[1][pos] = s
      tt++
    @nextBuffer = buffer
  gen: (e) =>
    @fillNextBuffer e.buffers, e.bufferSize
    return c.l "noBuff" unless @nextBuffer?
    e.buffers = @nextBuffer
    @nextBuffer = null

manualRun = (interval)->
  interval = interval||500
  setInterval (->
    mainGenerator.master.gen()
    setTimeout (->
      #res = mainGenerator.master.getSample()
      #c.l "result is", res
    ),interval/2
  ),interval


window.inits[400] =
  desc: "d3 stuff"
  init:()->
    #initA()
    initD3Gen()


addNode = null
draw = null


initD3Gen = ->
  window.nodes = nodes = []
  window.links = links = []
  nodesData = null
  h = window.innerHeight-50
  w = window.innerWidth-50

  svg = d3.select('body').append('svg').attr('height', h).attr('width', w)
  nodesData =  svg.append('svg:g').selectAll('g')
  edges =  svg.append('svg:g').selectAll('path')
  
  color = d3.scale.category20()


  c.l window.innerWidth

  bw = w/15
  bh = h/15
  r = 16

  generatorLength = 0

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
    
  genNodesLinks= ->
    genNodes()
    genLinks()

  genNodes = -> synth.parts.forEach (sp,i)-> addNode sp
  genLinks = ->
    nodes.forEach (sp,spi)->
      part = sp.data
      return unless part.outputs?
      sp.data.outputs.forEach (output, oi)-> addLink part, output


  connectNode = (e)->
    c.l "connect",d3.select(@)
    if !sourceNode?
      d3.select(@).classed("connect", true)
      sourceNode = e
    else
      if (sourceNode.data.outputs? && e.data.inputs?)&&sourceNode!=e # check if connectable
        ## TODO check for inifinite loop=
        dragPath.attr("d", "M0,0")
        checkInfinite()
        sourceNode.data.outputs.push e.data
        e.data.addInput sourceNode.data
        genLinks()
        draw()
        mainGenerator.findGenerators()
        sourceNode = null
        d3.select(".connect").classed("connect", false)

  checkInfinite = ()->
    generatorLength = 0
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

    synth.parts.forEach (part)->
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

  checkInfinite()
  genNodesLinks()
  ### Establish the dynamic force behavor of the nodes ###
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
    c.l pos, sourceNode.x
    dragPath.attr 'd', (d) ->
      x1 = sourceNode.x
      y1 = sourceNode.y
      x2 = pos[0]-2
      y2 = pos[1]-2

      'M' + x1 + ',' + y1 + ' L' + x2 + ',' + y2

  draw()
  window.draw = draw




window.onload = ->
  window.inits.forEach (init, i)->
    if init.desc then c.l init.desc
    init.init()
synth = null
window.inits[150] =
  desc: "init audio generator model"
  init: -> initModels()

initModels = ->

  class Model
    p: 0
    lastValues: new Uint8Array
    lastValue: 0
    constructor:->
      @id = Date.now()+"#"+Math.floor Math.random()*999999
      @outputs = [] if @outputs?
      @inputs = []
      @init() if @init?
    addInput: (input)->
      @updateLastValueArray()
      @inputs.push input
    getNewValues: (newSample)-> # gets newValue return oldValue
      returnValue = @lastValue
      @lastValue = newSample
      for input, i in @inputs
        @lastValues[i] = input.gen()
      returnValue
    updateLastValueArray: -> @lastValues = new Uint8Array @inputs.length+1
    process: -> 0
    gen: ->
      @getNewValues @process()



  class Generator
    constructor:-> @outputs = []
    type: "generator"
    p: 0 # phase
    freq: 440
    volume: 0.2
    mute: false
    outputs: []
    gen: ->
      @p += (@freq*256 / 44100)
      s = @p&@p>>8
      #c.l "ge&nSample: "+s
      s=(((s&255)-127)*@volume)+127
      #c.l s
      s

  class Mixer extends Model
    type: "mixer"
    activeMixer: "&"
    outputs: []
    inputBuffer: 0
    mixBuffer: null
    process: ->
      s = undefined
      for v,i in @lastValues then s = @mixers[@activeMixer](v, s)
      return s
    mixers:
      "|": (a,b)-> a | b||0
      "M": (a,b)-> (a + b||127) / 2
      "m": (a,b)-> (a * b||127) >> 8
      "&": (a,b)-> a & b||255
      "^": (a,b)-> a ^ b||0
      "+": (a,b)-> a + b||0
      "-": (a,b)-> a - b||0
      "*": (a,b)-> a * b||1
      "/": (a,b)-> a / b||1

  class Delay extends Model
    init: ->
      @buffer = new Uint8Array Pico.sampleRate*@seconds
      @p = 1
    type: "delay"
    dry: 0.5
    wet: 0.5
    seconds: 0.4
    buffer: null
    outputs:[]
    process: ()->
      smpl = @lastValues[0]
      bufSmpl = @buffer[@p]
      #c.l @buffer
      if @p<@buffer.length-1 then @p++ else @p = 1
      @buffer[@p-1] = smpl
      smpl = smpl*@dry + bufSmpl*@wet
      smpl

  class Master extends Model
    type: "master"
    process: ->
      s = 0
      #c.l @lastValues
      for v,i in @lastValues then s += v-127
      
      #if s>255 then s= 255
      if s>128 then s = 128
      else if s<-127 then s = -127
      #c.l "masterSample: "+s
      return s+127



  synth =
    parts : []
    partClasses:
      Generator: Generator
      Delay: Delay
      Mixer: Mixer
      Master: Master


window.inits[300] =
  desc: "Audiogenerator"
  init:()->
    #initWebAudio()

SAMPLERATE = 8000
BUFFERLENGTH = 16384
CHANNELS = 2

frequency = 0

document.addEventListener "mousemove", (e)->
  frequency = e.pageX

initWebAudio = ->
  # define online and offline audio context
  audioCtx = new AudioContext
  offlineCtx = new OfflineAudioContext CHANNELS, BUFFERLENGTH, SAMPLERATE

  scriptNode = audioCtx.createScriptProcessor(BUFFERLENGTH, 0, CHANNELS)
  offlineScriptNode = offlineCtx.createScriptProcessor(BUFFERLENGTH, 0, CHANNELS)

  bufferCtx = audioCtx.createBufferSource()
  offlineBuffer = offlineCtx.createBufferSource()

  t = 0
  scriptNode.onaudioprocess = (e) ->
    c.l "process--------------------------------"
    # The output buffer contains the samples that will be modified and played
    outputBuffer = e.outputBuffer
    # Loop through the output channels (in this case there is only one)
    channel = 0
    while channel < outputBuffer.numberOfChannels
      outputData = outputBuffer.getChannelData(channel)
      # Loop through the 4096 samples
      sample = 0
      while sample < outputBuffer.length
        p = (frequency*255) / SAMPLERATE
        # make output equal to the same as the input
        # add noise to each output sample
        s = (((t&t%255.5)))
        outputData[sample] = (((s&255)/128)-1)*0.3
        sample++
        t+=p
      channel++


  offlineCtx.oncomplete = (e) ->
    console.log 'Rendering completed successfully',e
    c.l e.renderedBuffer.getChannelData(0)
    bufferCtx.buffer = e.renderedBuffer


  scriptNode.connect audioCtx.destination
  #offlineScriptNode.connect offlineCtx.destination

  #bufferCtx.connect audioCtx.destination

  #offlineBuffer.start()
  #bufferCtx.start()
  #offlineCtx.startRendering()

  #c.l offlineScriptNode
  #c.l offlineCtx



  #source.loop = true;
  #source.loop= true
  #source.start()
  #window.s = source































# class BDGenerator extends Generator
#   init: -> @attrs.background = "#f48"
#   gen: (so) =>
#     s = (4*(@el.x*@el.x+1)) / (@p%((255<<13)>>@el.posy))
#     @p += 1
#     @applyRest so, s

# class HHGenerator extends Generator
#   init: -> @attrs.background = "#4f8"
#   gen: (so) =>
#     s = (Math.random()*(@el.x*@el.x+1)) / (@p%(((255<<13)>>@el.posy)))
#     @p += 1
#     @applyRest so, s

# class SynthGenerator extends Generator
#   init: -> @attrs.background = "#84f"
#   gen: (so) =>
#     t = @p
#     s = t&255
#     @p += (((@el.posx+1)*1000) / 44100)
#     @applyRest so, s

# class GateGenerator extends Generator
#   volume: 7
#   adderOptions: ["&","|","^","+","-"]
#   init: -> @attrs.background = "#48f"
#   gen: (so) =>
#     t = @p
#     s = t>>(@el.posx+@el.posy)
#     s = (s&1)*255
#     @p += 1
#     @applyRest so, s

# class MainGenerator
#   generators: []
#   resortGenerators: (chGen)->
#     @generators.forEach (gen, i)->
#       gen.el.posInfoEl.innerText = i
#     @showStackedView()
#   showStackedView: ->
#     stackedViewEl = document.getElementById("stackedView")
#     stackedViewEl.innerHTML = ""
#     @generators.forEach (gen, i)->
#       stack = document.createElement "span"
#       stack.innerHTML = i
#       stack.style.background = gen.el.style.background
#       stackedViewEl.appendChild stack
#   addBD: => @generators.push new BDGenerator(); @showStackedView(); drawAgain()
#   addHH: => @generators.push new HHGenerator(); @showStackedView(); drawAgain()
#   addSynth: => @generators.push new SynthGenerator(); @showStackedView(); drawAgain()
#   addGate: => @generators.push new GateGenerator(); @showStackedView(); drawAgain()
#   gen: (e) =>
#     out = e.buffers
#     i = 0 # buffer iterator
#     s = 0 # sample value
#     tt = 0 # global time for sequencing
#     while i < e.bufferSize
#       s = 127
#       @generators.forEach (gen,i)->
#         s = if !gen.mute then gen.gen(s) else s
#       s = 1-((s&255)/127)
#       s /= 3
#       out[0][i] = out[1][i] = s
#       if s>1||s<-1 then throw new Error("fatal sample is at value "+s)
#       i++

# mainGen = new MainGenerator()
# window.mainGen = mainGen