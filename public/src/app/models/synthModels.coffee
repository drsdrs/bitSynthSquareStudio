c = console; c.l = c.log

class IO
  p: 0
  envelopeValues: []
  lastValue: 0
  init: -> null
  gen: -> null
  # addOutput: (output)->
  #   output.inputs.push @
  #   @outputs.push output
  #   output.updateLastValueArray()

class SingleInput extends IO
  input: false
  constructor: ->
    @id = Date.now()+""+(Math.random()*9999)>>0
    @envelopes = []
    @envelopeValues.forEach (envName)=> @envelopes.push = new Envelope envName
    @init()
  addInput: (input)->
    if @input==false
      @input = input
    else throw new error("FATAL!!! ONLY ONE INPUT ALLOWED")

class MultiInput extends IO
  lastValues: []
  constructor: ->
    @inputs = []
    @envelopes = []
    @envelopeValues.forEach (envName)=> @envelopes.push = new Envelope envName
    @init()
  addInput: (input)->
    @updateLastValueArray()
    @inputs.push input
    @envelopes.push new Envelope "volume"
  getNewValues: (newSample)=> # gets newValue return oldValue
    for input, i in @inputs
      @lastValues[i] = input.gen() * @envelopes[i].value
  updateLastValueArray: -> @lastValues = new Uint8Array @inputs.length+1
  gen: -> null


class Envelope
  constructor: (type)->
    if type=="volume"
      @max = 1
      @min = 0
    else if type=="freq"
      @max = 20000
      @min = 0
      @graph = "bars"
  absolute: true
  graph: "bars"
  loop: true
  length: 16/4 # Length in beats
  max: 1
  min: 0
  value: 0
  gen: (beat)->
    pos = beat%@length
    start = 0
    if !@data[start]? then c.l "ERROR, no data??", start, @data
    while @data[start].time<pos then start++
    p1 = @data[start]
    if @data[start].time==pos then return p1.value
    p0 = @data[start-1]
    @value = (((pos-p0.time)*(p1.value-p0.value))/(p1.time-p0.time))+p0.value

  data: [
    {time: 0, value: 0.5}
    {time: 0.5, value: 1}
    {time: 1, value: 0.5}
    {time: 1.5, value: 1}
    {time: 2, value: 0.3}
    {time: 2.5, value: 0.15}
    {time: 4, value: 0.5}
  ]

class Generator
  envelopeValues: ["freq"]
  envelopes: []
  constructor:->
    @outputs = []
    @envelopeValues.forEach (envName,i)=> @envelopes[i] = new Envelope envName
  type: "generator"
  p: 127 # phase
  freq: 440
  mute: false
  outputs: []
  gen: ->
    s = @p#&@p>>8
    s = (((s&255)/127)-1)
    @p += (@freq*256 / 44100)
    s


class Delay extends SingleInput
  init: ->
    @buffer = new Float32Array 44100*@seconds
    @p = 0
  envelopeValues: ["dry", "wet", "seconds"]
  type: "delay"
  dry: 0.5
  wet: 0.5
  seconds: 0.4
  buffer: null
  gen: ->
    smpl = @input.gen()
    bufSmpl = @buffer[@p]
    @buffer[(@p)%@buffer.length] = smpl
    if @p<@buffer.length-1 then @p++ else @p = 0
    smpl = smpl*@dry + bufSmpl*@wet
    smpl

class Mixer extends MultiInput
  type: "mixer"
  activeMixer: "+"
  #mixBuffer: null
  gen: ->
    s = 0
    for v,i in @getNewValues() then s = @mixers[@activeMixer](v, s)
    return s
  mixers:
    "M": (a,b)-> (a + b||0) / 2
    "m": (a,b)-> (a * b||1) / 2
    "+": (a,b)-> a + b||0
    "-": (a,b)-> a - b||0
    "|": (a,b)-> a | b||0
    "&": (a,b)-> a & b||1
    "^": (a,b)-> a ^ b||0
    "*": (a,b)-> a * b||1
    "/": (a,b)-> a / b||1


class Master extends MultiInput
  type: "master"
  gen: ->
    s = 0
    for v,i in @getNewValues() then s += v
    if s>1 then s = 1 else if s<-1 then s = -1
    return s

define ->
  Generator: Generator
  Delay: Delay
  Master: Master
  Mixer: Mixer
