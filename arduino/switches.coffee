serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Switches
  name: "switches"

  constructor: (port, rate=9600) ->
    @connected = false
    @device = new SerialPort port,
      parser: serialport.parsers.readline "\r\n"
      baudrate: rate

    @cables = {}

    @device.on "error", (e) -> console.log e
    @device.on "open", =>
      @device.on "data", (data) =>
        if @connected
          @parseData(data)
        else if data is "\"#{@name}\""
          @connected = true
          console.log "Connected to device '#{@name}', waiting for input"

  parseData: (json) ->
    {pin, value} = JSON.parse(json)
    str = if value then "on" else "off"
    console.log "Switched #{pin} to #{str}"

module.exports = Switches