serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Lights
  name: "lights"

  constructor: (port, rate=9600) ->
    @connected = false
    @device = new SerialPort port,
      parser: serialport.parsers.readline "\r\n"
      baudrate: rate

    @device.on "error", (e) -> console.log e
    @device.on "open", =>
      @device.on "data", (data) =>
        if @connected
        else
          if data is "\"#{@name}\""
            console.log "Connected to device '#{@name}'"
            @connected = true
            @blink()
          else
            console.log "Received unexpected data: '#{data}'"

  blinkOn: false

  blink: ->
    val = (if @blinkOn then 1 else 0)
    @blinkOn = !@blinkOn
    for i in [13..53] 
      @device.write("#{i},")
      @device.write("#{val},")
    setTimeoutR 1000, (=> @blink())

module.exports = Lights