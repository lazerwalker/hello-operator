Gpio = require('onoff').Gpio
serialport = require "serialport"
SerialPort = serialport.SerialPort

INPUT_RATE = 9600
INPUT_PORT= "/dev/ttyUSB0"

leds = [25, 24, 23, 18, 22, 27, 17, 4]
pins = [12, 16, 20, 21, 5, 6, 13, 19]

iter = (i) ->
  pin = new Gpio(leds[i], "out")
  console.log "I am the #{i} LED on pin ##{leds[i]}"
  pin.writeSync(1)
  setTimeout (() -> 
    pin.writeSync(0)
    iter(i+1)
  ), 5000

# iter(0)

connect = () ->
  console.log "Connect two ports"
  @input = new SerialPort INPUT_PORT, 
    parser: serialport.parsers.readline "\n"
    baudrate: INPUT_RATE
    
  @input.on "open", =>
    @input.on "data", (data) =>
      event = JSON.parse(data)
      console.log("event:", event)

connect()
