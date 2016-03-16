RATE = 9600
PORT = "/dev/cu.usbmodem1411"

serialport = require "serialport"
SerialPort = serialport.SerialPort

device = new SerialPort PORT,
  parser: serialport.parsers.readline "\r\n"
  baudrate: RATE

setTimeoutR = (t, fn) -> setTimeout(fn, t)

blinkOn = false

blink = () ->
  val = (if blinkOn then 1 else 0)
  blinkOn = !blinkOn
  for i in [13..53] 
    device.write("#{i},")
    device.write("#{val},")
  setTimeout(blink, 1000)

device.on "error", (e) -> console.log e
device.on "open", ->
  device.on "data", (json) ->
    console.log json
    if json is '"leds"'
      console.log "Connected to device, waiting for input"
      blink()