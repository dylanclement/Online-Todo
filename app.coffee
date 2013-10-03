express = require 'express'
routes = require './src/routes'
todoRoutes = require './src/routes/todo'
http = require 'http'
path = require 'path'
mongoose = require('mongoose').connect 'mongodb://localhost/todo'

app = express()
db = mongoose.connection
db.on 'error', console.error.bind console, 'connection error:'
db.once 'open', -> console.log 'Opened connection to DB!'

# all environments
app.set 'port', process.env.PORT || 3000
app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.set 'title', 'Dylan\'s TODO app'
# app.use express.favicon()
app.use express.logger 'dev'
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use require('stylus').middleware(__dirname + '/public')
app.use require('coffee-middleware')
  src: "#{__dirname}/public"
  compress: true
app.use express.static(path.join(__dirname, 'public'))
app.use express.static(path.join(__dirname, 'vendor'))
# add a reference to the db to the request object
app.use (req, res, next) -> req.db = db; next()

# development only
if 'development' == app.get 'env'
  app.use express.errorHandler()

# routes
app.get '/', routes.index
app.get '/todos', todoRoutes.list
app.post '/todos', todoRoutes.add
app.get '/todo/:id', todoRoutes.get
app.put '/todo/:id', todoRoutes.update
app.del '/todo/:id', todoRoutes.del
app.post '/todos/re-order', todoRoutes.reOrder

http.createServer(app).listen app.get('port'), ->
  console.log "Todo app server listening on port #{app.get('port')}"
