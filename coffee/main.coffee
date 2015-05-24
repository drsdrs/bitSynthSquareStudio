window.onload = ->
  window.inits.forEach (init, i)->
    if init.desc then c.l init.desc
    init.init()