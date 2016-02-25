serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Lights
  constructor: (@device) ->
    @blink()
  blinkOn: false

  blink: ->
    val = (if @blinkOn then 1 else 0)
    @blinkOn = !@blinkOn
    for i in [13..53] 
      @device.write("#{i},")
      @device.write("#{val},")
    setTimeoutR 1000, (=> @blink())

module.exports = Lights