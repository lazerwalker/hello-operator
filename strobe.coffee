five = require("johnny-five")

plugFirst = 14
cableFirst = 33
last = 51

setTimeoutR = (t, fn) -> setTimeout(fn, t)

boards = [
  { id: "cables", port: "/dev/cu.usbmodem14221" },
  { id: "plugs", port: "/dev/cu.usbmodem14211" }
]

five.Boards(boards).on "ready", ->
  cableBoard = this.byId("cables")
  plugBoard = this.byId("plugs")
  console.log cableBoard.id, plugBoard.id
  ports = {}
  state = {}

  cables = {}

  # Configure ports
  for i in [plugFirst...last]
    do (i) ->
      pin = new five.Pin({
        pin: i
        mode: five.Pin.INPUT
        board: plugBoard
      })

      pin.write(1)
      pin.read (err, val) ->
        if val != state[i]
          console.log "#{i}: #{val}"
          state[i] = val
      ports[i] = pin

  for i in [cableFirst...last]
    do (i) ->
      pin = new five.Pin
        pin: i
        mode: five.Pin.OUTPUT
        board: cableBoard

      pin.write(0)
      cables[i] = pin

  theLoop = () ->
    for k,cable of cables
      cable.write(0)
    setTimeout(theLoop, 10)

  theLoop()

