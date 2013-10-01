mongoose = require 'mongoose'
_ = require 'lodash'

module.exports = class Todo

  todo: mongoose.model 'Todo', mongoose.Schema
    description: String
    done: Boolean
    due: Date
    pos: Number

  constructor: ->

  getAll: (cb) ->
    @todo.find (err, todos) ->
      if err then cb err
      return cb null, todos

  getNextPos: (cb) ->
    # Find the highest pos value and return that + 1
    @todo.find (err, todos) ->
      if err then cb err

      maxPos = _.max todos, (todo) -> return todo.pos
      return cb null, maxPos + 1


  add: (description, due, pos, cb) ->
    # Get the max pos and use that if undefined
    if !pos then return @getNextPos (err, maxPos) =>
      if err then return cb err
      return @add description, due, maxPos, cb

    # create a new todo item
    todo = new @todo
      description: description
      done: false
      due: due
      pos: pos

    # save it and if successful, return it
    todo.save cb

  save: (todo, cb) ->
    @todo.findById todo._id, (err, item) ->
      if err then return cb err
      if !item then return cb new Error "Unable to find todo item #{id}, #{item}"

      item.description = todo.description
      console.log 'Saving item', item
      item.save cb

  del: (id, cb) ->
    @todo.findById id, (err, item) ->
      if err then return cb err
      if !item then return cb new Error "Unable to find todo item #{id}, #{item}"

      console.log 'Removing item', item
      item.remove cb
