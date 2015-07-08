define [
  "cs!app/synth"
], (synth)->
  class MainGenerator
    startGenerators: []
    master : null
    nextBuffer: null
    processed: 0
    constructor: ->
      @findGenerators( synth[0] )
      @findMaster( synth[0] )
    findGenerators: (parts)->
      parts.forEach (part, i)=>
        @startGenerators.push part if part.type=="generator"
    findMaster: (parts)->
      parts.forEach (part, i)=> @master = part if part.type=="master"
    fillNextBuffer: (buffer, size)->
      i = 0 # buffer iterator
      s = 0 # sample value
      tt = 0 # global time for sequencing
      for data, pos in buffer[0]
        s =  @master.gen()
        s *= 0.5
        buffer[0][pos] = buffer[1][pos] = s
        tt++
      @nextBuffer = buffer
    gen: (e) =>
      @fillNextBuffer e.buffers, e.bufferSize
      return c.l "noBuff" unless @nextBuffer?
      e.buffers = @nextBuffer
      @nextBuffer = null