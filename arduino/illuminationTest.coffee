ArduinoGroup = require('./arduino_group')
SwitchState = require('../src/cablePair').SwitchState
Calibration = require('./calibration')

_ = require('underscore')

a = new ArduinoGroup([
  "/dev/cu.usbmodem14211"
  "/dev/cu.usbmodem14221"
  "/dev/cu.usbmodem14231"
  "/dev/cu.usbmodem14241"  
])

a.on "ready", =>
  map = new Calibration()
  for led in _.keys(map.mapping.cableLights)
    a.turnOffLight(led, true)

  for led in _.keys(map.mapping.portLights)
    a.turnOffLight(led)

  console.log "Have fun!"

  a.on 'connect', ({cable, port}) ->
    a.turnOnLight(cable, true)

    neighbors = []
    if port % 10 isnt 1
      neighbors.push port - 1
    if port % 10 isnt 0
      neighbors.push 1 + port

    if port > 11
      neighbors.push port - 10
    else
      neighbors.push port + 10

    console.log(port, neighbors)
    a.turnOnLight(n) for n in neighbors

  a.on 'disconnect', ({cable, port}) ->
    a.turnOnLight(cable, true)
    for led in _.keys(map.mapping.portLights)
      a.turnOffLight(led)


  a.on 'toggleSwitch', ({switchNum, position}) ->
    if position is SwitchState.Neutral
      a.turnOffLight(switchNum, true)
    else
        a.turnOnLight(switchNum, true)      

