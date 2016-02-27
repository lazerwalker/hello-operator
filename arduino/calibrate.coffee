_ = require('underscore')
fs = require('fs')

SwitchState = require('../src/cablePair').SwitchState
ArduinoGroup = require('./arduino_group')

g = new ArduinoGroup([
  "/dev/cu.usbmodem14211"
  "/dev/cu.usbmodem14221"
  "/dev/cu.usbmodem14111"
  "/dev/cu.usbmodem14121"  
])

setTimeoutR = (t, fn) -> setTimeout(fn, t)

existing = fs.readFileSync("#{__dirname}/latestCalibration.json")
if existing
  state = JSON.parse(existing)
  console.log "Existing state loaded", state
else
  state = {}

calibrateCables = ->
  cable = g.cables

  console.log "\n\nBEGINNING CABLE CALIBRATION"
  console.log "---------------------------\n"

  currentCable = 1
  currentRow = "R"
  maxCable = 10

  state.cables = {}

  console.log "Please plug in cable #1R"

  cable.on "connect", ({cable, port}) ->
    return if _.contains state.cables, cable

    index = "#{currentCable}#{currentRow}"
    state.cables[index] = cable

    if currentRow is "R"
      currentRow = "F"
    else
      currentCable++
      currentRow = "R"

    console.log JSON.stringify(state.cables, null, 2)

    if currentCable > maxCable
      console.log "Thank you for calibrating cables!"
      calibratePorts()
    else
      console.log "Please plug in cable ##{currentCable}#{currentRow}"

calibratePorts = ->
  cable = g.cables
  cable.debug = true

  console.log "\n\nBEGINNING PORT CALIBRATION"
  console.log "---------------------------\n"

  currentPort = 1
  maxPort = 20

  state.ports = {}

  console.log "Please plug a cable into port #1"

  cable.on "connect", ({cable, port}) ->
    return if _.contains state.ports, port

    state.ports[currentPort] = port
    currentPort++
    console.log JSON.stringify(state.ports, null, 2)

    if currentPort > maxPort
      console.log "Thank you for calibrating ports!"
      console.log JSON.stringify(state, null, 2)
      calibratePortLights()
    else
      console.log "Please plug a cable into port ##{currentPort}"

calibrateSwitches = ->
  s = g.switches

  console.log "\n\nBEGINNING SWITCH CALIBRATION"
  console.log "---------------------------\n"

  current = 1
  currentRow = "R"
  currentDir = "talk"
  max = 10

  state.switches = {}

  console.log "Please flip switch #1R to talk"

  seenPins = []

  s.on "change", ({pin, value}) ->
    return if value is true

    return if _.contains seenPins, pin
    seenPins.push pin

    index = "#{current}#{currentRow}"
    state.switches[index] ?= {}
    state.switches[index][currentDir] = pin

    if currentDir is "talk"
      currentDir = "ring"
    else # move to the next switch
      if currentRow is "R"
        currentRow = "F"
        currentDir = "talk"
      else # move to the next row
        currentRow = "R"
        currentDir = "talk"
        current++
        if current > max
          console.log "Thank you for calibrating switches!"
          console.log JSON.stringify(state, null, 2)
          # calibratePortLights()
          return

    console.log JSON.stringify(state.switches, null, 2)
    console.log "Got it! Please flip switch ##{current}#{currentRow} to #{currentDir}"

calibratePortLights = ->
  cable = g.cables
  light = g.portLights

  unless (cable? and light?)
    console.log "Either cable or light was null", cable, light
    return

  console.log "\n\nBEGINNING PORT LIGHT CALIBRATION"
  console.log "---------------------------\n"

  # TODO
  currentPin = 32
  lastPin = 51

  light.turnOff(pin) for pin in [currentPin..lastPin]

  state.portLights = {}

  light.turnOn(currentPin)
  console.log "Turning on pin #{currentPin}. Please plug a cable into the illuminated port."

  cable.on "connect", ({cable, port}) ->
    portNum = _.invert(state.ports)[port]
    console.log "#{port} -> #{portNum}"

    return if _.contains state.portLights, portNum

    state.portLights[portNum] = currentPin
    light.turnOff(currentPin)
    currentPin++

    console.log JSON.stringify(state.portLights, null, 2)

    if currentPin > lastPin
      console.log "Thank you for calibrating port lights!"
      console.log JSON.stringify(state, null, 2)
      # calibrateCableLights()
    else
      light.turnOn(currentPin)
      console.log "Turning on pin #{currentPin}. Please plug a cable into the illuminated port"

calibrateCableLights = ->
  switches = g.switches
  light = g.cableLights
  light.debug = true
  unless (switches? and light?)
    console.log "Either switches or light was null", switches, light
    return

  console.log "\n\nBEGINNING PORT LIGHT CALIBRATION"
  console.log "---------------------------\n"

  # TODO
  currentPin = 10
  lastPin = 51

  light.turnOff(pin) for pin in [currentPin..lastPin]

  state.cableLights = {}

  light.turnOn(currentPin)
  console.log "Turning on pin #{currentPin}. Please move the illuminated switch to Ring."

  switches.on "change", ({pin, value}) ->
    # Figure out what was changed
    result = _.chain(state.switches)
      .pairs()
      .find( (obj) -> obj[1].talk is pin || obj[1].ring is pin )
      .value()

    if result
      position = if result[1].talk is pin then SwitchState.Talk else SwitchState.Ring
      changed = {num: result[0], position}

    return if _.contains state.cableLights, changed.num
    
    position = SwitchState.Neutral
    if changed.num[changed.num.length - 1] is "R" and changed.position is SwitchState.Talk
      if value is true
        position = SwitchState.Talk
      else if value is false
        position = changed.position

    # Do the real thing
    if changed.position is SwitchState.Talk
      console.log "Skipping"
    else if changed.position is SwitchState.Ring
      state.cableLights[currentPin] = changed.num
    else
      return

    light.turnOff(currentPin)
    currentPin++

    console.log JSON.stringify(state.cableLights, null, 2)

    if currentPin > lastPin
      console.log "Thank you for calibrating port lights!"
      console.log JSON.stringify(state, null, 2)
      calibrateCableLights()
    else
      light.turnOn(currentPin)
      console.log "Turning on pin #{currentPin}. Please move the illuminated switch to Ring"

g.debug = false
g.on 'ready', => (setTimeoutR 3000, calibratePortLights)

