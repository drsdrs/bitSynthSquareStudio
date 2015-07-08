module.exports = (io)->
  midi = require 'midi'
  MIDIUtils = require 'midiutils'

  input = new midi.input()

  # show all available inputs
  inputLen = input.getPortCount()
  while inputLen--
    console.log input.getPortName inputLen

  input.on 'message', (deltaTime, message)->
    if message[0]==248 then return io.broadcast "clock", true
    else if message[0]==250 then return io.broadcast "start", true
    else if message[0]==251 then return io.broadcast "continue", true
    else if message[0]==252 then return io.broadcast "stop", true
    #else console.log message[0]
    nibbleA = (message[0]&0b11110000)>>4
    nibbleB = message[0]&0b1111
    noteOn = if nibbleA==9 then true else if nibbleA==8 then false else undefined
    vel = if noteOn then message[2]||0 else 0
    noteOn = if vel>0 then true else false
    noteFreq = MIDIUtils.noteNumberToFrequency message[1]
    io.broadcast "midiEvent", { on: noteOn, note: noteFreq ,vel: vel }

  input.openPort(0)

  # Order: (Sysex, Timing, Active Sensing)
  input.ignoreTypes(true, false, true)