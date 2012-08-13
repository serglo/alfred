###
# Router of chat application
###
class App extends Backbone.Router

  routes:
    "/chat": "main"

  initialize: ->
    _.bindAll @

    @appView      = new AppView
    @contactsView = new ContactsView
    @chatView     = new ChatView

    @socket = io.connect()
    @socket.on 'connect', =>
      @appView.loading false
      @appView.setSocket @socket
      @contactsView.setSocket @socket
      @chatView.setSocket @socket

    @socket.on 'disconnect', =>
      @appView.loading true


new App
Backbone.history.start()
