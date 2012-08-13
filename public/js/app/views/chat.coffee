###
# Chat view
###
class ChatView extends View

  el: $ '.chatWindow'

  initialize: ->
    super
    @messageTemplate       = _.template $('.template-chat-message').html()
    @messageAppendTemplate = _.template $('.template-chat-message-append').html()
    scrollPane             = $(@el).jScrollPane()
    @scrollPane            = scrollPane.data 'jsp'
    @messageContainer      = $ '.messages', @el

  setSocket: (socket) ->
    super
    @socket.on 'message', (data) =>
      @renderMessage {
        user: data.user
        content: data.message
      }
    @socket.on 'user.self', (data) =>
      @user = data.user

  renderMessage: (data) ->
    data.content = @messageParser data.content

    lastMessage = $('.message', @messageContainer).last()
    if lastMessage.data('from') == data.user._id
      $('.bubble', lastMessage).append @messageAppendTemplate data
    else
      element = $ @messageTemplate data
      element.data 'from', data.user._id
      if data.user._id == @user._id
        element.addClass 'self'
      @messageContainer.append element

    @scrollPane.reinitialise()
    @scrollPane.scrollToPercentY 100

  messageParser: (message) ->
    @linkyfy (message)

  ###
  # Message plugins and stuff
  ###
  linkyfy: (message) ->
    #URLs starting with http://, https://, or ftp://
    replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim
    message = message.replace replacePattern1, '<a href="$1" target="_blank">$1</a>'

    #URLs starting with "www." (without // before it, or it'd re-link the ones done above).
    replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
    message = message.replace replacePattern2, '$1<a href="http://$2" target="_blank">$2</a>'

    #Change email addresses to mailto:: links.
    replacePattern3 = /(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/gim;
    message = message.replace replacePattern3, '<a href="mailto:$1">$1</a>'

    message
