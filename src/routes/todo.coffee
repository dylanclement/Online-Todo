todo = require '../models/todo'

exports.list = (req, res, next) ->
  todo.getAll (err, todos) ->
    console.log 'Todos = ', todos
    res.json todos