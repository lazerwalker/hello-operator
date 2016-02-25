serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Switches
  constructor: (@device, @debug=false) ->
    @callbacks = {}

    @timeouts = {}

    @device.on "error", (e) -> console.log e
    @device.on "data", (data) =>
      @parseData(data)

  parseData: (json) ->
    {pin, value} = JSON.parse(json)
    if @timeouts[pin]?
      clearTimeout @timeouts[pin]
      delete @timeouts[pin]
      return

    @timeouts[pin] = setTimeoutR 50, =>
      @trigger "change", {pin, value}
      delete @timeouts[pin]

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