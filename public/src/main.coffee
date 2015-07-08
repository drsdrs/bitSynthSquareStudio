require [
  "cs!app/MainGenerator"
  "cs!app/views/synthView"
  "cs!app/views/editView"
  "cs!app/synth"
  "cs!app/models/synthModels"
  "lib/pico.min"
  "/socket.io/socket.io.js"
], (MainGenerator, synthView, editView, synth, models, pico, socket)->
  

  gen = new models.Generator
  mix = new models.Mixer
  dly = new models.Delay
  mstr = new models.Master

  dly.addInput gen
  mix.addInput dly
  mstr.addInput mix

  synth[0].push gen
  synth[0].push mix
  synth[0].push dly
  synth[0].push mstr

  synthView.genNodesLinks synth[0]
  synthView.draw()

  editView.init synth[0]

  io = socket.connect()
  io.on "midiEvent", (d)-> gen.freq = d.note||gen.freq

  cc = 0
  stopped = false
  io.on "clock", ->
    unless stopped
      processEnvelopes()
      cc++
      
  io.on "start", ->
    if stopped
      stopped = false
      cc = 0
      processEnvelopes()


  io.on "stop", ->
    stopped = true
    cc = 0
    processEnvelopes()
  io.on "continue", -> stopped = false

  processEnvelopes= ()->
    for synthParts in synth then for synthPart in synthParts
      for env in synthPart.envelopes
        env.gen(cc/24)

  mainGenerator = new MainGenerator
  pico.play mainGenerator.gen