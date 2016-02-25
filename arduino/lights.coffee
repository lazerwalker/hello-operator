serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Lights
  constructor: (@device) ->
    @turnOn(i) for i in [13..52]

  turnOn: (num) ->
    @device.write("#{num}")
    @device.write("1")

  turnOff: (num) ->
    @device.write("#{num}")
    @device.write("0")    

module.exports = Lights