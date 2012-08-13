###
# Contacts View
###
class ContactsView extends View

  el: $ '.contactList'

  initialize: ->
    super

    @onlineUsers = new Users
    @onlineUsers.on 'reset', @renderUserList
    @onlineUsers.on 'add', @appendUser
    @onlineUsers.on 'remove', @removeUser

    @userlistUserTemplate = _.template $('.template-userlist-user').html()

  setSocket: (socket) ->
    super

    @socket.on 'user.list', (data) =>
      @onlineUsers.reset data.userlist

    @socket.on 'user.joined', (data) =>
      @onlineUsers.add data.user

    @socket.on 'user.left', (data) =>
      @onlineUsers.remove @onlineUsers.get data.user._id

  appendUser: (user) ->
    item = $ @userlistUserTemplate { user: user.toJSON() }
    item.hide().data('user-id', user._id)
    $('ul.others', @el).append item.fadeIn()

  removeUser: (user) ->
    $('ul.others li', @el).each ->
      $(@).remove() if $(@).data('user-id') == user._id

  renderUserList: ->
    $('ul.others', @el).empty()
    @appendUser user for user in @onlineUsers.models
