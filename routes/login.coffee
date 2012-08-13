module.exports = (req, res) ->
  if req.user
    res.redirect '/chat'
  else
    res.render 'login', { title: 'Login' }

