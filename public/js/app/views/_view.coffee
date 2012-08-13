###
# View for all chat views
###
class View extends Backbone.View
  initialize: ->
    _.bindAll @
    @socket = @options.socket if @options?.socket?

  setSocket: (socket) ->
    @socket = socket
