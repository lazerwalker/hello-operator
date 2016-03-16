serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Cables
  constructor: (@device, @debug = false) ->
    @callbacks = {}
    @cables = {}

    @device.on "error", (e) -> console.log e
    @device.on "data", (data) =>
      @parseData(data)

  parseData: (json) ->
    {connected, cable, port} = JSON.parse(json)
    oldPort = @cables[cable]

    if connected is true and oldPort is port
      return
    else if connected is false and oldPort isnt port
      return
    else if connected is true and not oldport?
      @cables[cable] = port
      @trigger "connect", {cable, port}
      console.log "Connected #{cable} to #{port}" if @debug
    else if connected is false and oldPort is port
      delete @cables[cable]
      @trigger "disconnect", {cable, port}
      console.log "Disconnected #{cable} and #{port}" if @debug

  # Events
  on: (event, cb) ->
    @callbacks[event] ?= []
    @callbacks[event].push cb

  trigger: (event, data) ->
    return unless @callbacks[event]?
    cb(data) for cb in @callbacks[event]


module.exports = Cables