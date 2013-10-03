passport = require 'passport'
User = require './models/user'
LocalStrategy = require('passport-local').Strategy;

userModel = new User

passport.use new LocalStrategy (username, password, cb) ->
  userModel.get username, (err, user) ->
    if err then return cb err
    if !user or !userModel.validatePassword user, password
      return cb null, false, message: 'Incorrect username or password.'

    return cb null, user

passport.serializeUser (user, cb) ->
  cb null, user.id

passport.deserializeUser (id, cb) ->
  userModel.getById id, cb

exports.createUser = (username, password, cb) ->
  userModel.create username, password, cb
