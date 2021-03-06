Todo = require '../models/todo'

# instantiate the todo class
todo = new Todo

exports.list = (req, res, next) ->
  todo.getAll req.user._id, (err, todos) ->
    console.log 'Todos =', todos
    if err then return next err

    res.json todos


exports.add = (req, res, next) ->
  newTodo = req.body
  console.log 'New Todo = ', newTodo
  todo.add newTodo.description, newTodo.due, newTodo.pos, req.user.id, (err, newTodo) ->
    if err then return next err

    return res.json newTodo

exports.get = (req, res, next) ->
  todo.get req.params.id, (err, todo) ->
    if err then return next err

    res.json todo

exports.update = (req, res, next) ->
  editedTodo = req.body
  console.log 'Editing ', editedTodo
  todo.save editedTodo, (err, item) ->
    if err then return next err

    return res.json item

exports.del = (req, res, next) ->
  id = req.params.id
  console.log 'Deleting todo', id
  todo.del id, req.user.id, (err, item) ->
    if err then return next err

    return res.json {success: true}

exports.reOrder = (req, res, next) ->
  start = req.body.start
  end = req.body.end
  console.log 'Trying to re-order', start, end, req.user.id
  todo.reOrder start, end, req.user.id, (err) ->
    if err then return next err

    return res.json {success: true}