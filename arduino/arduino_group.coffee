_ = require('underscore')
serialport = require "serialport"
SerialPort = serialport.SerialPort

Calibration = require('./calibration')

Switches = require('./switches')
Cables = require('./cables')
Lights = require('./lights')

SwitchState = require('../src/cablePair').SwitchState

deviceTypes = 
  cables: Cables
  switches: Switches
  lights: Lights

class ArduinoGroup
  constructor: (ports=[], rate=9600) ->
    @map = new Calibration()

    @devices = []

    @callbacks = {}

    devices = _.map ports, (port) ->
      new SerialPort port,
        parser: serialport.parsers.readline "\r\n"
        baudrate: 9600

    _.each devices, (rawDevice) =>
      connected = false
      rawDevice.on "data", (data) =>
        return if connected
        name = JSON.parse(data)
        return unless name? and deviceTypes[name]

        connected = true
        console.log "Found a #{name} at #{rawDevice.path}"

        d = new deviceTypes[name](rawDevice)
        @devices.push d 
        @[name] = d

        if @devices.length is ports.length
          @trigger('ready')

    @on 'ready', ->
      @cables.on 'connect', ({cable, port}) ->
        cableNum = @map.cableNumFromPin(cable)
        portNum = @map.portNumFromPin(port)        
        @trigger 'connect', {cable: cableNum, port: portNum}

      @cables.on 'disconnect', ({cable, port}) ->
        cableNum = @map.cableNumFromPin(cable)
        portNum = @map.portNumFromPin(port)        
        @trigger 'disconnect', {cable: cableNum, port: portNum}

      # pin = arduino pin
      # output: {switchNum: "1R", position: SwitchState.TALK}
      @switches.on 'change', ({pin, value}) ->
        @trigger 'toggleSwitch', @map.switchNumFromPin(pin)

  turnOnLight: (num, isCable = false) ->
    if isCable
      pin = @map.cableLightFromNum(num)
      @cableLights?.turnOn(pin)
    else
      pin = @map.portLightFromNum(num)
      @portLights?.turnOn(pin)

  turnOffLight: (num) ->
    if isCable
      pin = mapping.cableLights[num]
      @cableLights?.turnOff(pin)
    else
      pin = mapping.portLights[num]
      @portLights?.turnOff(pin)

  # TODO: why the fuck am I rolling my own event emitter?
  on: (event, cb) ->
    @callbacks[event] ?= []
    @callbacks[event].push cb

  trigger: (event, data) ->
    return unless @callbacks[event]?
    cb(data) for cb in @callbacks[event]


module.exports = ArduinoGroup
