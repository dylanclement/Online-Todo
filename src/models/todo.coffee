mongoose = require 'mongoose'
_ = require 'lodash'

module.exports = class Todo

  todo: mongoose.model 'Todo', mongoose.Schema
    description: String
    done: Boolean
    due: Date
    pos: Number
    user: String

  constructor: ->

  get: (id, cb) ->
    @todo.findById id, (err, todo) ->
      if err then cb err
      return cb null, todo

  getAll: (user, cb) ->
    @todo.find({user}).sort(pos: 1).exec (err, todos) ->
      if err then cb err
      return cb null, todos


  getNextPos: (user, cb) ->
    # Find the highest pos value and return that + 1
    # TODO! what about findOne().sort(pos: -1) ?
    @todo.find({user}).exec (err, todos) ->
      if err then cb err

      # Cater for an empty list
      if !todos.length then return cb null, 0

      maxPos = _.max todos, (todo) -> return todo.pos
      return cb null, maxPos.pos + 1


  add: (description, due, pos, user, cb) ->
    console.log 'Add', description, due, pos, user
    # Get the max pos and use that if undefined
    if !pos? then return @getNextPos user, (err, maxPos) =>

      if err then return cb err
      return @add description, due, maxPos, user, cb

    # create a new todo item
    todo = new @todo
      description: description
      done: false
      due: due
      pos: pos
      user: user

    console.log 'Adding new Todo', todo
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

  del: (id, user, cb) ->
    @todo.findById id, (err, item) =>
      if err then return cb err
      if !item then return cb new Error "Unable to find todo item #{id}, #{item}"

      console.log 'Removing item', item
      item.remove (err) =>
        if err then return err

        # move all elements below it up the priority chain
        # first get all todo items
        @todo.find({user}).sort(pos: 1).exec (err, todos) ->
          if err then cb err

          # loop through them and move anything that was higher up down 1
          retTodos = todos.forEach (todo) ->
            if todo.pos > item.pos
              todo.pos -= 1
              console.log 'Saving todo', todo
              todo.save()
              return todo

          # return the new list to the front end
          cb null, retTodos

  reOrder: (start, end, user, cb) ->
    console.log 'Re-Ordering ', start, end
    @todo.find({user}).sort(pos: 1).exec (err, todos) ->
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
            todo.save()
      cb()
