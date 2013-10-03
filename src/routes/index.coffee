auth = require '../auth'

exports.index = (req, res) ->
  res.render 'index', title: 'Dylan\'s TODO app'

exports.login = (req, res) ->
  msg = req.flash('error')[0]
  console.log msg
  res.render 'user', {msg}

exports.register = (req, res, next) ->
  user = req.body
  auth.createUser user.username, user.password, (err) ->
    if err then return next err
    res.json {success: true}
