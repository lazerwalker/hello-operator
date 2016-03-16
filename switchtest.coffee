RATE = 9600
PORT = "/dev/cu.usbmodem1411"

serialport = require "serialport"
SerialPort = serialport.SerialPort

device = new SerialPort PORT,
  parser: serialport.parsers.readline "\r\n"
  baudrate: RATE

cables = {}

setTimeoutR = (t, fn) -> setTimeout(fn, t)

device.on "error", (e) -> console.log e
device.on "open", ->
  device.on "data", (json) ->
    if json is '"switches"'
      console.log "Connected to device, waiting for input"
      return

    {pin, value} = JSON.parse(json)
    str = if value then "on" else "off"
    console.log "Switched #{pin} to #{str}"