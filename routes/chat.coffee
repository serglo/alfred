module.exports = (req, res) ->
  if !req.user
    res.redirect '/login'
  else
    res.render 'chat', {
      title: 'Chat'
      user: req.session.user
    }
