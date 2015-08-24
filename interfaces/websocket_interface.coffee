_ = require 'underscore'
WebSocketServer = require('ws').server

class WebsocketInterface
  constructor: (@people, @client) ->
    wss = new WebSocketServer port: 8080
    wss.on 'connection', (ws) ->
      @client = ws
      ws.on 'message', (message) ->
        # TODO: Major security hole. Whitelist commands.
        {command, data} = JSON.parse message
        @[command]?(data)

  connectOperator: (sender) -> @client.connectOperator(sender)
  disconnectOperator: (sender) -> @client.disconnectOperator(sender)
  connect: (a, b) -> @client.connect(a, b)
  disconnect: (a,b) -> @client.disconnect(a, b)

  sendMessage: (command, data) ->
    @client?.send JSON.stringify({command, data})

  initiateCall: (sender) ->
    @sendMessage "initiateCall", sender

  askToConnect: (call) ->
    @sendMessage "askToConnect", call

  completeCall: (call) ->
    @sendMessage "completeCall", call

  waitForInput: () ->
    process.stdin.resume();
    process.stdin.setEncoding('utf8');

    process.stdin.on 'data', (text) =>
      match = text.match /(\w+) (\w+)/
      [first, second] = [match[1], match[2]]

      if first is "me" or second is "me"
        other = if first is "me" then second else first
        if other in @connected
          console.log "Disconnected #{other} and operator"
          @client.disconnectOperator(other)
        else
          @disconnectExisting(other)
          console.log "Connected #{other} to operator"
          @connected.push [other, "me"]
          @client.connectOperator(other)
      else if first in @people and second in @people
        if _.find(@connected, (pair) -> first in pair and second in pair)
          console.log "Disconnected #{first} and #{second}."
          @client.disconnect(first, second)
        else
          @disconnectExisting(c) for c in [first, second]

          console.log "Connected #{first} and #{second}."
          @connected.push [first, second]
          @client.connect(first, second)



module.exports = WebsocketInterface