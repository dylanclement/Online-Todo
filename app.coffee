express = require 'express'
routes = require './src/routes'
todoRoutes = require './src/routes/todo'
http = require 'http'
path = require 'path'
mongoose = require('mongoose').connect('mongodb://localhost/todo')

app = express()
db = mongoose.connection
db.on 'error', console.error.bind(console, 'connection error:')
db.once 'open', -> console.log 'Opened connection to DB!'

# all environments
app.set 'port', process.env.PORT || 3000
app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use express.favicon()
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

app.get '/', routes.index
app.get '/todos', todoRoutes.list

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
