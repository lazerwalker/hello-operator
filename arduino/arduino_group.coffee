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
            console.log "Found a #{name}"
            console.log @
            d = new deviceTypes[name](rawDevice)
            @devices.push(d)
            connected = true


module.exports = ArduinoGroup
