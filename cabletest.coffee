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
    if json is '"cables"'
      console.log "Connected to device, waiting for input"
      return

    {connected, cable, port} = JSON.parse(json)
    oldPort = cables[cable]

    if connected is true and oldPort is port
      return
    else if connected is false and oldPort isnt port
      return
    else if connected is true and not oldport?
      cables[cable] = port
      console.log "Connected #{cable} to #{port}"
    else if connected is false and oldPort is port
      delete cables[cable]
      console.log "Disconnected #{cable} and #{port}"
