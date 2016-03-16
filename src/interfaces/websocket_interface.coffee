_ = require 'underscore'
WebSocket = require('ws')

class WebSocketInterface
  constructor: (url) ->
    @people = []
    @client = []

    @connected = false
    @socket = new WebSocket(url)
    @socket.on 'open', (ws) =>
      @connected = true
      cb() for cb in @onReadyCallbacks

    @socket.on 'message', (message) =>
      # TODO: Whitelist expected commands.
      [command, args...] = message.split(",")
      @[command]?(args...)

  clientJoined: ->
    @sendCommand "people", @people

  sendCommand: (command, args...) ->
    return unless @connected
    string = [command, args].join(",")    
    @socket.send string

  setPeople: (people) ->
    @sendCommand "people", people

  # -

  didConnect: (cable, port) ->
    @sendCommand "didConnect", [cable, port]

  didDisconnect: (cable, port) ->
    @sendCommand "didDisconnect", [cable, port]

  didToggleSwitch: (cable, position) ->
    @sendCommand "didToggleSwitch", [cable, position]

  # -

  connect: (cable, port) ->
    @client?.connect?(cable, port, this)

  disconnect: (cable, port) ->
    @client?.disconnect?(cable, port, this)

  toggleSwitch: (switchNum, position) ->

    @client?.toggleSwitch?(switchNum, parseInt(position), this)

  # -

  turnOnLight: (caller, blink = false) ->
    @sendCommand "turnOnLight", caller


  turnOffLight: (caller, blink = false) ->
    @sendCommand "turnOffLight", caller

  blinkLight: ({caller, rate}) ->
    @sendCommand "blinkLight", caller, rate

  sayToConnect: ({sender, receiver}) ->
    @sendCommand "sayToConnect", sender, receiver


  onReady: (cb) ->
    @onReadyCallbacks ?= []
    @onReadyCallbacks.push cb
    if @connected
      cb()

module.exports = WebSocketInterface