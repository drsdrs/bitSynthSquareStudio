c = console; c.l = c.log
require("coffee-script/register")
path = require("path")

express = require('express.io')
app = express()
app.http().io()


require('./server/midiComm.coffee')(app.io)




app.use "/", express.static(path.join(__dirname, "public"))
app.use "/lib", express.static(path.join(__dirname, "bower_components"))

app.get "/", (req, res, next) ->
  res.render "index",
    title: "OVERVIEW"




app.listen 3000, -> console.log 'listening on *:3000'
