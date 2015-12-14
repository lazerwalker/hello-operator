Gpio = require('onoff').Gpio
_ = require 'underscore'
cp = require 'child_process'

serialport = require 'serialport'
SerialPort = serialport.SerialPort

INPUT_RATE = 9600
INPUT_PORT= "/dev/ttyUSB0"

mapping = {
  "1A":
    "led": 22
    "plug": 27
  "1B":
    "led": 27
    "plug": 22
  "1C":
    "led": 17
    "plug": 13 
  "1D":
    "led": 4
    "plug": 19
  "2A":
    "led": 25
    "plug": 26
  "2B":
    "led": 24 
    "plug": 23
  "2C":
    "led": 26
    "plug": 24
  "2D":
    "led": 18
    "plug": 18              
  }

operatorPlug = 17

plugToName = (plug) ->
  _(mapping).findWhere({plug}).name

class RpiInterface
  constructor: ->
    SerialPort = require("serialport").SerialPort
    @peopleMap = _(mapping).each (p, n) ->
      p.name = n
      #p.ledPin = new Gpio(p.led, 'out')

    pins = _.pluck(mapping, 'plug')
    pins.push operatorPlug

    p = cp.fork "interfaces/rpi_scanner.coffee", [JSON.stringify(pins)]
    me = @
    p.on 'message', (m) ->
      #console.log m
      if operatorPlug in m.pins
        otherPin = _.without(m.pins, operatorPlug)[0]
        other = plugToName(otherPin) 
        if m.type is "on"
          console.log "Connecting operator"
          me.client.connectOperator other
        else
          me.client.disconnectOperator other 
      else
        if m.type is "on"
          me.client.connect plugToName(m.pins[0]), plugToName(m.pins[1])
        else
          me.client.disconnect plugToName(m.pins[0]), plugToName(m.pins[1])

  initiateCall: (sender) ->
    console.log "Talk to #{sender}" 
    pin = @peopleMap[sender].ledPin
    #pin.write(1)

  askToConnect: ({sender, receiver}) ->
    pin = @peopleMap[sender].ledPin
    #pin.write(0)
    console.log "#{sender} wants to talk to #{receiver}" 

  completeCall: ({sender, receiver}) ->
    console.log "#{sender} and #{receiver} are finished talking"

module.exports = RpiInterface
