###
# Application View for global stuff
###
class AppView extends View

  el: $ '.app'

  events:
    "click .btn.code": "shareCode"
    "submit .newMessage": "sendMessage"

  initialize: ->
    super
    @inputField = $ '.newMessage .text', @el
    @inputField.focus();

  sendMessage: ->
    message = @inputField.val()
    @inputField.val ''
    @socket.emit 'message', { message: message }
    return false

  shareCode: ->

  loading: (state) ->
