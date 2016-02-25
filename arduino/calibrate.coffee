_ = require('underscore')

ArduinoGroup = require('./arduino_group')

g = new ArduinoGroup([
  "/dev/cu.usbmodem14211"
  "/dev/cu.usbmodem14221"
  "/dev/cu.usbmodem14111"
  "/dev/cu.usbmodem14121"  
])

setTimeoutR = (t, fn) -> setTimeout(fn, t)

state = {}

calibrateCables = ->
  return unless g.cables.length is 1
  cable = g.cables[0]

  console.log "\n\nBEGINNING CABLE CALIBRATION"
  console.log "---------------------------\n"

  currentCable = 1
  maxCable = 10

  state.cables = {}

  console.log "Please plug in cable #1"

  cable.on "connect", ({cable, port}) ->
    return if _.contains state.cables, cable

    state.cables[currentCable] = cable
    currentCable++
    console.log state.cables

    if currentCable > maxCable
      console.log "Thank you for calibrating cables!"
      calibratePorts()
    else
      console.log "Please plug in cable ##{currentCable}"

calibratePorts = ->
  return unless g.cables.length is 1
  cable = g.cables[0]

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
    console.log state.ports

    if currentPort > maxPort
      console.log "Thank you for calibrating cables!"
      console.log state
    else
      console.log "Please plug a cable into port ##{currentPort}"

calibrateSwitches = ->
  return unless g.switches.length is 1
  s = g.switches[0]

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

    state.switches[current] ?= {}
    state.switches[current][currentRow] ?= {}
    state.switches[current][currentRow][currentDir] = pin

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
          return

    console.log state.switches
    console.log "Got it! Please flip switch ##{current}#{currentRow} to #{currentDir}"


g.on 'ready', => (setTimeoutR 2000, calibrateCables)

