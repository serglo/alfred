_           = require 'underscore'
io          = require 'socket.io'
http        = require 'http'
express     = require 'express'
path        = require 'path'
everyauth   = require 'everyauth'
cookie      = require 'cookie'
connect     = require 'connect'
MemoryStore = express.session.MemoryStore
store       = null
app         = express()
cradle      = require 'cradle'
db          = new (cradle.Connection)().database 'chat'
routes      = []
require('fs').readdirSync('./routes').forEach (file) ->
  routes[file.replace '.coffee', ''] = require "./routes/#{file}" if file.match /\.coffee$/g

###
# Configure database
###
db.exists (err, exists) ->
  if err
    console.log 'error', err
  else if exists
    console.log 'database exists'
  else
    db.create (err, create) ->
      if err
        console.log 'error', err
      else
        console.log 'database created'

###
# Configure everyauth authentication methods
###
findOrCreateUser = (service, id, data, promise) ->
  switch service
    when 'twitter'
      cleanData =
        name: data.screen_name
        location: data.location
        avatar: data.profile_image_url
        profilelink: "http://twitter.com/#{data.screen_name}"
        service: 'twitter'
    when 'github'
      cleanData =
        name: data.login
        location: data.location
        avatar: data.avatar_url
        profilelink: "http://github.com/#{data.login}"
        service: 'github'
    when 'facebook'
      cleanData =
        name: data.username
        fullname: data.name
        location: data.location.name
        avatar: data.picture.data.url
        profilelink: data.link
        service: 'facebook'

  db.save "#{service}-#{id}", cleanData, (err, user) ->
    if err
      promise.fulfill [err]
    else if user
      promise.fulfill user
  promise

everyauth.everymodule.findUserById (userId, callback) ->
  db.get "#{userId}", callback


everyauth.twitter
  .consumerKey(process.env.twitter_consumerKey)
  .consumerSecret(process.env.twitter_consumerSecret)
  .redirectPath('/')
  .findOrCreateUser (session, accessToken, accessTokenSecret, twitterData) ->
    promise = @Promise()
    findOrCreateUser 'twitter', twitterData.id, twitterData, promise

everyauth.github
  .appId(process.env.github_appid)
  .appSecret(process.env.github_appsecret)
  .redirectPath('/')
  .findOrCreateUser (session, accessToken, accessTokenExtra, ghData) ->
    promise = @Promise()
    findOrCreateUser 'github', ghData.id, ghData, promise

everyauth.facebook
  .appId(process.env.facebook_appId)
  .appSecret(process.env.facebook_appSecret)
  .redirectPath('/')
  .fields(process.env.facebook_fields)
  .findOrCreateUser (session, accessToken, accessTokenExtra, fbData) ->
    promise = @Promise()
    findOrCreateUser 'facebook', fbData.id, fbData, promise

###
# Configure the application
###
app.configure ->
  app.set 'port', process.env.PORT or 3000
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session {
    secret: process.env.sessionSecret or 'kjahsdgf8as71123as'
    key: 'express.sid'
    store: store = new MemoryStore()
  }
  app.use everyauth.middleware()
  app.use app.router
  app.use require('less-middleware') {
    src: "#{__dirname}/public"
  }
  app.use express.static path.join __dirname, 'public'

app.configure 'development', ->
  app.use express.errorHandler()

server = http.createServer app
sio = io.listen server

###
# Routes for application
###
app.get '/', routes.index
app.get '/login', routes.login
app.get '/chat', routes.chat

###
# Socket authorization stuff
###
sio.set 'authorization', (data, accept) ->
  if not data.headers.cookie
    return accept 'No cookie transmitted', false

  data.cookie = connect.utils.parseSignedCookies cookie.parse(decodeURIComponent(data.headers.cookie)), process.env.sessionSecret or 'kjahsdgf8as71123as'
  data.sessionID = data.cookie['express.sid']

  data.store = store
  store.load data.sessionID, (err, session) ->
    if err or not session
      return accept 'Error', false
    data.session = session
    accept null, true
  return

onlineUsers = [];

###
# Socket awesomeness
###
sio.sockets.on 'connection', (socket) ->
  hs   = socket.handshake
  user = hs.session.user

  if user
    socket.join 'chatroom'

    #add user to the array
    onlineUsers.push user
    #clean up and remove duplicate users
    onlineUsers = _.uniq onlineUsers, false, (el) -> el._id

    socket.broadcast.to('chatroom').emit 'user.joined', { user: user }
    socket.emit 'user.list', {
      userlist: _.filter onlineUsers, (u) ->
        u._id != user._id
    }
    socket.emit 'user.self', { user: user }

    keepAlive = setInterval ->
      hs.session.reload ->
        hs.session.touch().save()
    , 10 * 1000

    socket.on 'disconnect', ->
      socket.broadcast.to('chatroom').emit 'user.left', { user: user }
      socket.leave 'chatroom'
      onlineUsers = _.filter onlineUsers, (el) ->
        el._id != user._id
      clearInterval keepAlive

    socket.on 'message', (data) ->
      if data.message
        sio.sockets.emit 'message', {
          user: user
          message: data.message
        }

###
# Oh boy, I almost forgot to listen to a port
###
server.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get 'port' }"
