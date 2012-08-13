module.exports = (req, res) ->
  if !req.user
    res.redirect '/login'
  else
    req.session.user = req.user
    res.redirect '/chat'
