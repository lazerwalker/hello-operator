_ = require('underscore')
serialport = require "serialport"
SerialPort = serialport.SerialPort

Switches = require('./switches')
Cables = require('./cables')
Lights = require('./lights')

deviceTypes = 
  cables: Cables
  switches: Switches
  lights: Lights

class ArduinoGroup
  constructor: (ports=[], rate=9600) ->
    @devices = []

    @callbacks = {}

    devices = _.map ports, (port) ->
      new SerialPort port,
        parser: serialport.parsers.readline "\r\n"
        baudrate: 9600

    _.each devices, (rawDevice) =>
      rawDevice.on "open", =>
        connected = false
        rawDevice.on "data", (data) =>
          return if connected
          name = JSON.parse(data)
          if name? and deviceTypes[name]
            connected = true
            console.log "Found a #{name}"

            d = new deviceTypes[name](rawDevice)
            @devices.push d 
            @[name] ?= []
            @[name].push d

  turnOnLight: (num) ->
    @lights[0]?.turnOn(num)

  turnOffLight: (num) ->
    @lights[0]?.turnOff(num)

  # TODO: why the fuck am I rolling my own event emitter?
  on: (event, cb) ->
    @callbacks[event] ?= []
    @callbacks[event].push cb

  trigger: (event, data) ->
    return unless @callbacks[event]?
    cb(data) for cb in @callbacks[event]

module.exports = ArduinoGroup
