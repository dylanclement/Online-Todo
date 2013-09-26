mongoose = require 'mongoose'

exports.todoSchema = mongoose.Schema
  description: String
  complete: Boolean

Todo = mongoose.model 'Todo', exports.todoSchema

exports.getAll = (cb) ->
  Todo.find (err, todos) ->
    if err then cb err
    return cb null, todos