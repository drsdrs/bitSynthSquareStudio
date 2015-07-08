c =  console; c.l = c.log

requirejs = require 'requirejs'
assert = require "assert"

requirejs.config
    nodeRequire: require
    baseUrl: './public/src'
    paths:
      "cs": 'lib/cs'
      "coffee-script": 'lib/coffee-script'

models = requirejs "cs!app/models/synthModels.coffee"


beforeEach ()->
  done = ()-> c.l "done"
  this.timeout(done, 2500)
  setTimeout(done, 2300);



#############################################
### ------------- GENERATOR ------------- ###
#############################################

describe 'Generator Class', ->
  gen = new models.Generator

  gen.freq = 44100/256
  gen.volume = 1

  it 'should return correct sawtooth values', ->
    assert.equal 0, gen.gen() 
    assert.equal 0.007874015748031482, gen.gen() 
    assert.equal 0.015748031496062964, gen.gen()
    assert.equal 3, Math.round((gen.gen()+1)*127)-127
    assert.equal 4, Math.round((gen.gen()+1)*127)-127



#############################################
### --------------- MIXER --------------- ###
#############################################

describe 'Mixer Class', ->
  gen1 = new models.Generator
  gen2 = new models.Generator
  gen3 = new models.Generator
  mix = new models.Mixer

  gen1.freq = 44100/256
  gen2.freq = 44100/256
  gen3.freq = 44100/256
  gen1.volume = 1
  gen2.volume = 1
  gen3.volume = 1

  mix.addInput gen1
  mix.addInput gen2
  mix.addInput gen3

  for env in mix.envelopes then env.value = 1

  it 'should sum correct', ->
    assert.equal 0, mix.gen()
    assert.equal 0.023622047244094446, mix.gen()
    assert.equal 0.04724409448818889, mix.gen()
    assert.equal 0.07086614173228334, mix.gen()



#############################################
### ------------- ENVELOPE  ------------- ###
#############################################

describe "Envelope Class", ->
  it 'should interpolated value', ->
    gen = new models.Generator
    env = gen.envelopes[0]
    env.data = [
      {time: 0, value: 100}
      {time: 0.5, value: -100}
      {time: 1, value: -300}
    ]
    assert.equal 100, env.gen(0)
    assert.equal -100, env.gen(0.5)
    assert.equal 0, env.gen(0.25)
    assert.equal -200, env.gen(0.75)
    assert.equal -300, env.gen(1)


#############################################
### --------------  DELAY  -------------- ###
#############################################

describe "Delay Class", ->
  it 'should buffer values', ->
    dly = new models.Delay
 
    dly.wet = 1
    dly.dry = 0
    dly.buffer = new Float32Array 4

    assert.equal 0, dly.gen 1
    assert.equal 0, dly.gen 2
    assert.equal 0, dly.gen 3
    assert.equal 0, dly.gen 4
    assert.equal 1, dly.gen 0
    assert.equal 2, dly.gen 0
    assert.equal 3, dly.gen 0
    assert.equal 4, dly.gen 0
    assert.equal 0, dly.gen 0
    assert.equal 0, dly.gen 0
    assert.equal 0, dly.gen 0
    assert.equal 0, dly.gen 0

  it 'should return value', ->
    dly = new models.Delay
 
    dly.wet = 0
    dly.dry = 1
    dly.buffer = new Float32Array 4

    assert.equal 1, dly.gen 1
    assert.equal 2, dly.gen 2
    assert.equal 3, dly.gen 3

  it 'should return mixed value', ->
    dly = new models.Delay
 
    dly.wet = 0.5
    dly.dry = 0.5
    dly.buffer = new Float32Array 4

    assert.equal 0.5, dly.gen 1
    assert.equal 1, dly.gen 2
    assert.equal 1.5, dly.gen 3
    assert.equal 2, dly.gen 4
    assert.equal 1, dly.gen 1
    assert.equal 2, dly.gen 2
    assert.equal 3, dly.gen 3
    assert.equal 4, dly.gen 4
    assert.equal 1, dly.gen 1
    assert.equal 2, dly.gen 2
    assert.equal 3, dly.gen 3
    assert.equal 4, dly.gen 4


#############################################
### -------------- MASTER  -------------- ###
#############################################

describe 'Master Class', ->
  gen1 = new models.Generator
  gen2 = new models.Generator
  gen3 = new models.Generator
  mix = new models.Master

  gen1.freq = 44100/256
  gen1.volume = 1
  gen2.freq = 44100/256
  gen2.volume = 1
  gen3.freq = 44100/256
  gen3.volume = 1

  mix.addInput gen1
  mix.addInput gen2
  mix.addInput gen3
  for env in mix.envelopes then env.value = 1

  it 'should sum correct', ->
    assert.equal 0, mix.gen()
    assert.equal 0.023622047244094446, mix.gen()
    assert.equal 0.04724409448818889, mix.gen()
    assert.equal 0.07086614173228334, mix.gen()


#############################################
### ------------ COMBINED  -------------- ###
#############################################

describe 'Combine all Classes', ->
  gen1 = new models.Generator
  gen2 = new models.Generator
  gen3 = new models.Generator
  mix = new models.Mixer
  dly = new models.Delay
  mstr = new models.Master

  dly.wet = 1
  dly.dry = 0
  dly.buffer = new Float32Array 4

  gen1.freq = 44100/256
  gen2.freq = 44100/256
  gen3.freq = 44100/256
  gen1.volume = 1
  gen2.volume = 1
  gen3.volume = 1

  mix.addInput gen1
  mix.addInput gen2
  mix.addInput gen3
  dly.addInput mix
  mstr.addInput dly
  mstr.addInput gen1

  c.l gen1.gen()
  c.l gen1.gen()
  c.l gen1.gen()
  c.l gen1.gen()
  c.l gen1.gen()
  c.l gen1.gen()
  c.l mix.gen()
  c.l mix.gen()
  c.l mix.gen()
  c.l mix.gen()
  c.l mix.gen()
  c.l mix.gen()
  c.l mix.gen()
  c.l mix.gen()
  c.l mix.gen()


  for env in mix.envelopes then env.value = 1

  it 'should sum correct', ->
    assert.equal 0, mix.gen()
    assert.equal 0.023622047244094446, mix.gen()
    assert.equal 0.04724409448818889, mix.gen()
    assert.equal 0.07086614173228334, mix.gen()