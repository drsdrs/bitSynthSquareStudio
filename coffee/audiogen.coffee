window.inits[200] =
  desc: "Audiogenerator"
  init:()->
    document.getElementById("newBD").addEventListener "click", mainGen.addBD
    document.getElementById("newHH").addEventListener "click", mainGen.addHH
    document.getElementById("newSynth").addEventListener "click", mainGen.addSynth
    c.l new HHGenerator(0)
    #Pico.play mainGen.gen


applyStyle = (el)-> for key,val of el.attrs then el.style[key]= val


max = w:window.innerWidth, h:window.innerHeight
activeOffset = x:0,y:0
activeEl = null
activeAttrs = {}

dragActive = (e)->
  if activeEl?
    y = e.y-activeOffset.y
    x = e.x-activeOffset.x
    if y>max.y then y = max.y
    if x>max.x then x = max.x
    if y<0 then y = 0
    if x<0 then x = 0
    x = activeEl.posx = Math.round(x/activeEl.attrs.width)
    y = activeEl.posy = Math.round(y/activeEl.attrs.height)
    activeEl.infoEl.innerText = x+":"+y
    activeEl.style.left = activeEl.x = x*activeEl.attrs.width
    activeEl.style.top = activeEl.y = y*activeEl.attrs.height

dragEnd = -> activeEl = null

document.addEventListener "mousemove", dragActive, false
document.addEventListener "touchmove", dragActive, false

document.addEventListener "mouseup", dragEnd, false
document.addEventListener "touchend", dragEnd, false


generatorContructor= (pos)->
  @init() if @init
  @pos = pos
  @el = document.createElement("div")
  @el.attrs = @attrs
  @el.x = @el.y = @el.posx = @el.posy = 0
  @el.classList.add "instrument"

  # pseudo click field for dragging
  dragField = document.createElement("div")
  dragField.addEventListener "mousedown", @makeActive, false
  dragField.addEventListener "touchstart", @makeActive, false
  dragField.classList.add "dragField"
  @el.appendChild dragField
  
  # X and Y position infos Plus audioSumBtn & anotherFX
  infoRow = document.createElement "div"
  @el.infoEl = document.createElement("span")
  @el.infoEl.innerHTML = null
  # audio summing method
  @adderEl = document.createElement("button")
  @adderEl.addEventListener "click", @changeAdder, false
  @adderEl.innerHTML = @adderOptions[@adder]
  # audio summing methodanotherFx
  @fxEl = document.createElement("button")
  @fxEl.addEventListener "click", null, false
  @fxEl.innerHTML = "?"

  infoRow.appendChild @fxEl
  infoRow.appendChild @el.infoEl
  infoRow.appendChild @adderEl

  @el.appendChild infoRow

  # volume elements
  volRow = document.createElement("div")
  @volumeEl = document.createElement("span")
  plusVolumeEl = document.createElement("button")
  minusVolumeEl = document.createElement("button")
  plusVolumeEl.innerHTML = "+"
  minusVolumeEl.innerHTML = "-"
  @volumeEl.innerText = @volume
  volRow.appendChild minusVolumeEl
  volRow.appendChild @volumeEl
  volRow.appendChild plusVolumeEl

  plusVolumeEl.addEventListener "click", @plusVolume, false
  minusVolumeEl.addEventListener "click", @minusVolume, false

  @el.appendChild volRow

  # position elements
  posRow = document.createElement("div")
  @posInfoEl = document.createElement("span")
  plusPosEl = document.createElement("button")
  minusPosEl = document.createElement("button")
  @posInfoEl.innerHTML = @pos
  plusPosEl.innerHTML = "+"
  minusPosEl.innerHTML = "-"

  plusPosEl.addEventListener "click", @plusPos, false
  minusPosEl.addEventListener "click", @minusPos, false

  posRow.appendChild minusPosEl
  posRow.appendChild @posInfoEl
  posRow.appendChild plusPosEl

  @el.appendChild posRow

  # append elements and make active
  applyStyle @el
  document.getElementById("container").appendChild @el

  activeEl = @el
  activeOffset = x: @attrs.width/2, y: @attrs.height/2
  @


class Generator
  constructor: generatorContructor
  p: 0
  attrs:
    left: max.w/2
    top: max.h/2
    width: 48
    height: 48
    background: "grey"
  volume: 7
  adder: 0
  adderOptions: ["|","&","^","+","-"]
  adders: [
    (a,b)-> a|b
    (a,b)-> a&b
    (a,b)-> a^b
    (a,b)-> a+b
    (a,b)-> a-b
  ]
  changeAdder: =>
    @adder += 1
    @adder %= @adderOptions.length
    @adderEl.innerHTML = @adderOptions[@adder]

  plusVolume: (e)=> @volume++; @changeVolume()
  minusVolume: (e)=> @volume--; @changeVolume()
  changeVolume: =>
    @volume = @volume&7
    @volumeEl.innerText = @volume

  plusPos: (e)=> @pos++; @changePosition()
  minusPos: (e)=> @pos--; @changePosition()
  changePosition: =>
    c.l @pos
    len = mainGen.generators.length
    if @pos>len then @pos = 0
    else @pos<0 then @pos = len
    c.l @pos

    mainGen.resortGenerators()
    @posInfoEl.innerText = @pos

  makeActive: (e)=>
    c.l "makeActive"
    activeEl = @el
    activeOffset =
      x: e.offsetX
      y: e.offsetY

  applyRest: (sampleOld, sample)->
    s = (s&255)>>(7-@volume)
    @adders[@adder] sampleOld, sample


class BDGenerator extends Generator
  init: -> @attrs.background = "#f48"
  gen: (so) =>
    s = (4*(@el.x*@el.x+1)) / (@p%((255<<13)>>@el.posy))
    @applyRest so, s
    @p += 1

class HHGenerator extends Generator
  init: -> @attrs.background = "#4f8"
  gen: (so) =>
    s = (1*(@el.x*@el.x+1)) / (Math.random()*(@p%((255<<13)>>@el.posy)))
    @applyRest so, s
    @p += 1

class SynthGenerator extends Generator
  init: -> @attrs.background = "#84f"
  gen: (so) =>
    t = @p
    s = (Math.cos(t+(t&(255-@el.posx))))*127
    @applyRest so, s
    @p += (((@el.posx+1)*55) / 44100)

class MainGenerator
  generators: []
  resortGenerators: ->
    newGenerator = []
    @generators.forEach (gen)=>
      newGenerator[gen.pos] = gen
      gen.el.posInfoEl = gen.pos

  addBD: => @generators.push new BDGenerator(@generators.length)
  addHH: => @generators.push new HHGenerator(@generators.length)
  addSynth: => @generators.push new SynthGenerator(@generators.length)
  gen: (e) =>
    out = e.buffers
    i = 0
    s = 0
    while i < e.bufferSize
      @generators.forEach (gen,i)->
        s = gen.gen(s)
      s = 1-((s&255)/127)
      s /= 3
      #s = Math.sin(s)
      out[0][i] = out[1][i] = s
      if s>1||s<-1 then throw new Error("fatal sample is at value "+s)
      i++

mainGen = new MainGenerator()
