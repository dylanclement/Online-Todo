Todo = require '../models/todo'

# instanciate the todo class
todo = new Todo

exports.list = (req, res, next) ->
  todo.getAll (err, todos) ->
    res.json todos

exports.add = (req, res, next) ->
  newTodo = req.body
  todo.add newTodo.description, null, null, (err, newTodo) ->
    if err then return next err
    return res.json newTodo

exports.update = (req, res, next) ->
  editedTodo = req.body
  console.log 'Editing ', editedTodo
  todo.save editedTodo, (err, item) ->
    if err then return next err
    return res.json item

exports.del = (req, res, next) ->
  id = req.params.id
  console.log 'Deleting todo', id
  todo.del id, (err, item) ->
    if err then return next err
    return res.json {success: true}