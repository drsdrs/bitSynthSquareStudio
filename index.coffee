c = console; c.l = c.log


require("coffee-script/register")

path = require("path")
#favicon = require("serve-favicon")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
exec = require("child_process").exec

express = require('express')
app = express()

http = require('http').Server(app)


# view engine setup
#app.set "env", "development"
#app.set "views", path.join(__dirname, "views")
#app.set "view engine", "ejs"
#app.set 'port', process.env.PORT || 3000
#app.use(favicon(__dirname + '/public/favicon.ico'))
#app.use bodyParser.json()
#app.use bodyParser.urlencoded(extended: false)
#app.use cookieParser()



app.use "/", express.static(path.join(__dirname, "public"))
app.use "/lib", express.static(path.join(__dirname, "bower_components"))

app.get "/", (req, res, next) ->
  res.render "index",
    title: "OVERVIEW"




http.listen 3000, -> console.log 'listening on *:3000'
