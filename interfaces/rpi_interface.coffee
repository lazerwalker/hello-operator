Gpio = require('onoff').Gpio
_ = require 'underscore'
serialport = require 'serialport'
SerialPort = serialport.SerialPort

INPUT_RATE = 9600
INPUT_PORT= "/dev/ttyUSB0"

mapping = {
  "1A":
    "led": 22
    "plug": 12
  "1B":
    "led": 27
    "plug": 10
  "1C":
    "led": 17
    "plug": 9
  "1D":
    "led": 4
    "plug": 11
  "2A":
    "led": 25
    "plug": 7
  "2B":
    "led": 24 
    "plug": 8
  "2C":
    "led": 23
    "plug": 5
  "2D":
    "led": 18
    "plug": 6              
  }

operatorPlug = 4

plugToName = (plug) ->
  _(mapping).findWhere({plug}).name

class RpiInterface
  constructor: ->
    SerialPort = require("serialport").SerialPort
    @peopleMap = _(mapping).each (p, n) ->
      p.name = n
      p.ledPin = new Gpio(p.led, 'out')

    input = new SerialPort INPUT_PORT,
      parser: serialport.parsers.readline "\n"
      baudrate: INPUT_RATE

    input.on "open", =>
      input.on "data", (data) =>
        e = JSON.parse(data)
        if operatorPlug in e.values
          otherPin = _.without(e.values, operatorPlug)[0]
          other = plugToName(otherPin) 
          if e.type is "on"
            @client.connectOperator other
          else
            @client.disconnectOperator other 
        else
          if e.type is "on"
            @client.connect plugToName(e.values[0]), plugToName(e.values[1])
          else
            @client.disconnect plugToName(e.values[0]), plugToName(e.values[1])

  initiateCall: (sender) ->
    pin = @peopleMap[sender].ledPin
    pin.write(1)

  askToConnect: ({sender, receiver}) ->
    pin = @peopleMap[sender].ledPin
    pin.write(0)
    console.log "#{sender} wants to talk to #{receiver}" 

  completeCall: ({sender, receiver}) ->
    console.log "#{sender} and #{receiver} are finished talking"

module.exports = RpiInterface
