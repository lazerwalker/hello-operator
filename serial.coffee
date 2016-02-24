RATE = 9600
CABLE_PORT = "/dev/cu.usbmodem14211"
PLUG_PORT = "/dev/cu.usbmodem14221"

serialport = require "serialport"
SerialPort = serialport.SerialPort

cable = new SerialPort CABLE_PORT,
  parser: serialport.parsers.readline "\r\n"
  baudrate: RATE

plug = new SerialPort PLUG_PORT,
  parser: serialport.parsers.readline "\r\n"
  baudrate: RATE
cables = {}

setTimeoutR = (t, fn) -> setTimeout(fn, t)

cable.on "error", (e) -> console.log "CABLE: ", e
plug.on "error", (e) -> console.log "PLUG: ", e

semaphore = 0
semaphoreFn = ->
  semaphore++
  doTheThing() if semaphore >= 2

cable.on "open", semaphoreFn
plug.on "open", semaphoreFn

doTheThing = ->
  plug.on "data", (json) ->
    if json is '"hello"'
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
