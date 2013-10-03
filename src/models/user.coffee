mongoose = require 'mongoose'
_ = require 'lodash'
bcrypt = require 'bcrypt'

module.exports = class User

  user: mongoose.model 'User', mongoose.Schema
    username: String
    password: String
    lastlogin: Date

  constructor: ->

  get: (username, cb) ->
    @user.findOne {username}, cb

  getById: (id, cb) ->
    @user.findById id, cb


  create: (username, password, cb) ->
    bcrypt.hash password, 8, (err, hash) =>
      if err then return cb err

      newUser = new @user
        username: username
        password: hash
        lastlogin: null

      newUser.save cb


  save: (user, cb) -> user.save cb

  validatePassword: (user, password, cb) ->
    return bcrypt.compareSync password, user.password