mongoose = require 'mongoose'
_ = require 'lodash'

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
    newUser = new @user
      username: username
      password: password
      lastlogin: null

    newUser.save cb


  save: (user, cb) -> user.save cb

  validatePassword: (user, password, cb) -> password is user.password