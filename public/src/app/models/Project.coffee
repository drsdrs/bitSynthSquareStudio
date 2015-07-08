define [
  "cs!app/models/synthModels"
], (synthModels)->
  class Model
    constructor: (args)->
      for argKey, val of args
        c.l argKey, val
        if @[keyVal] then @[keyVal]= val else c.l ""
      @id = Date.now()+""+Math.floor Math.random()*999999
      @init() if @init

  class Synth extends Model
    init: ->
      if @parts.length==0
        @parts.push new synthModels.Generator
        @parts.push new synthModels.Master
    parts: []

  class Pattern extends Model
    init: -> null
    synth: null
    data: []

  class Project
    init: ->
      if @synths.length==0 then @synths.push new Synth
      if @patterns.length==0 then @patterns.push new Pattern
    songData: null
    patterns: []
    synths: []
