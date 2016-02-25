serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Switches
  constructor: (@device) ->
    @cables = {}

    @device.on "error", (e) -> console.log e
    @device.on "data", (data) =>
      @parseData(data)

  parseData: (json) ->
    {pin, value} = JSON.parse(json)
    str = if value then "on" else "off"
    console.log "Switched #{pin} to #{str}"

module.exports = Switches