passport = require 'passport'
bcrypt = require 'bcrypt'
User = require './models/user'
LocalStrategy = require('passport-local').Strategy
DigestStrategy = require('passport-http').DigestStrategy

userModel = new User

authenticate = (username, password, cb) ->
  userModel.get username, (err, user) ->
    if err then return cb err
    if !user or !userModel.validatePassword user, password
      return cb null, false, message: 'Incorrect username or password.'

    return cb null, user

passport.use new LocalStrategy authenticate
passport.use new DigestStrategy qop: 'auth',
  (username, cb) ->
    userModel.get username, (err, user) ->
      if err then return cb err
      if !user then return cb null, false
      return cb null, user, user.password

passport.serializeUser (user, cb) ->
  cb null, user.id

passport.deserializeUser (id, cb) ->
  userModel.getById id, cb

exports.createUser = (username, password, cb) ->
  userModel.create username, password, cb
