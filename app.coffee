flash = require 'connect-flash'
express = require 'express'
routes = require './src/routes'
todoRoutes = require './src/routes/todo'
http = require 'http'
path = require 'path'
passport = require 'passport'
mongoose = require('mongoose').connect 'mongodb://localhost/todo'


###############################################################################
# Configuration
###############################################################################
app = express()
db = mongoose.connection
db.on 'error', console.error.bind console, 'connection error:'
db.once 'open', -> console.log 'Opened connection to DB!'
# all environments
app.set 'port', process.env.PORT || 3000
app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
# app.use express.favicon()
app.use express.logger 'dev'
app.use express.cookieParser()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.session secret: 'dylan todo'
app.use flash()
app.use passport.initialize()
app.use passport.session()
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


###############################################################################
# Authentication routes
###############################################################################
app.get '/login', routes.login
# register a new user
app.post '/auth/register', routes.register

# main login point
app.post '/auth/login', passport.authenticate 'local',
  successRedirect: '/'
  failureRedirect: '/login'
  failureFlash: true
# When the user wants to logout
app.get '/logout', (req, res) ->
  req.logout()
  res.redirect '/login'

# Simple route middleware to ensure user is authenticated.
#   Use this route middleware on any resource that needs to be protected.  If
#   the request is authenticated (typically via a persistent login session),
#   the request will proceed.  Otherwise, the user will be redirected to the
#   login page.
ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated() then return next()
  else if req.body.user and req.body.password then return res.send 'Not authenticated', 401
  res.redirect '/login'

###############################################################################
# Application routes
###############################################################################
app.get '/', ensureAuthenticated, routes.index # Home page for single page app
app.all '/app*', ensureAuthenticated
app.all '/api*', passport.authenticate 'digest', session: false
app.post '/app/todos/re-order', todoRoutes.reOrder
app.get /\/ap.\/todos/, todoRoutes.list
app.post /\/ap.\/todos/, todoRoutes.add
app.get '/app/todo/:id', todoRoutes.get
app.get '/api/todo/:id', todoRoutes.get
app.put '/app/todo/:id', todoRoutes.update
app.put '/api/todo/:id', todoRoutes.update
app.del '/app/todo/:id', todoRoutes.del
app.del '/api/todo/:id', todoRoutes.del


http.createServer(app).listen app.get('port'), ->
  console.log "Todo app server listening on port #{app.get('port')}"
