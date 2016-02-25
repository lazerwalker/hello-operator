serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Switches
  constructor: (@device, @debug=false) ->
    @callbacks = {}
    @cables = {}

    @device.on "error", (e) -> console.log e
    @device.on "data", (data) =>
      @parseData(data)

  parseData: (json) ->
    {pin, value} = JSON.parse(json)
    @trigger "change", {pin, value}

    if @debug
      str = if value then "on" else "off"
      console.log "Switched #{pin} to #{str}"

  # Events
  on: (event, cb) ->
    @callbacks[event] ?= []
    @callbacks[event].push cb

  trigger: (event, data) ->
    return unless @callbacks[event]?
    cb(data) for cb in @callbacks[event]

module.exports = Switches