five = require("johnny-five")

plugPins = [22, 51]
cablePins = [14, 21]

setTimeoutR = (t, fn) -> setTimeout(fn, t)

five.Board("/dev/cu.usbmodel14211").on "ready", ->
  ports = {}
  state = {}

  cables = {}

  # Configure ports
  for i in [plugPins[0]..plugPins[1]]
    do (i) ->
      pin = new five.Pin
        pin: i
        mode: five.Pin.INPUT

      pin.read (err, val) ->
        if val != state[i]
          console.log "#{i}: #{val}"
          state[i] = val
      ports[i] = pin

  for i in [cablePins[0]..cablePins[1]]
    do (i) ->
      pin = new five.Pin
        pin: i
        mode: five.Pin.OUTPUT

      pin.write(0)
      cables[i] = pin

  theLoop = () ->
    for k,cable of cables
      five.Pin.write(cable, 0)
    setTimeout(theLoop, 10)

  theLoop()

