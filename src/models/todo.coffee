mongoose = require 'mongoose'
_ = require 'lodash'

module.exports = class Todo

  todo: mongoose.model 'Todo', mongoose.Schema
    description: String
    done: Boolean
    due: Date
    pos: Number

  constructor: ->

  get: (id, cb) ->
    @todo.findOne _id: id, (err, todo) ->
      if err then cb err
      return cb null, todo

  getAll: (cb) ->
    @todo.find().sort(pos: 1).exec (err, todos) ->
      if err then cb err
      return cb null, todos


  getNextPos: (cb) ->
    # Find the highest pos value and return that + 1
    # TODO! what about findOne().sort(pos: -1) ?
    @todo.find (err, todos) ->
      if err then cb err

      # Cater for an empty list
      if !todos.length then return cb null, 0

      maxPos = _.max todos, (todo) -> return todo.pos
      console.log 'Next pos = ', maxPos.pos
      return cb null, maxPos.pos + 1


  add: (description, due, pos, cb) ->
    # Get the max pos and use that if undefined
    if !pos? then return @getNextPos (err, maxPos) =>

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
    console.log 'Saving todo', todo
    @todo.findById todo._id, (err, item) ->
      if err then return cb err
      if !item then return cb new Error "Unable to find todo item #{id}, #{item}"

      item.description = todo.description
      item.due = todo.due
      item.done = todo.done
      console.log 'Saving item', item
      item.save cb

  del: (id, cb) ->
    @todo.findById id, (err, item) ->
      if err then return cb err
      if !item then return cb new Error "Unable to find todo item #{id}, #{item}"

      console.log 'Removing item', item
      item.remove cb

  reOrder: (start, end, cb) ->
    console.log 'Re-Ordering ', start, end
    @todo.find().sort(pos: 1).exec (err, todos) ->
      if err then return cb err

      #moved up
      if start > end
        todos.map (todo) ->
          # update the initial element
          if todo.pos == start
            todo.pos = end
            todo.save()
          # move the ones in between up +1
          else if end <= todo.pos < start
            todo.pos += 1
            console.log 'Updating todo', todo
            todo.save()
      # moved down
      else if start < end
        todos.map (todo) ->
          # update the initial element
          if todo.pos == start
            todo.pos = end
            todo.save()
          # move the ones in between up +1
          else if start < todo.pos <= end
            todo.pos -= 1
            console.log 'Updating todo', todo
            todo.save()
      cb()
