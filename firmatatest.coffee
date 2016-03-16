Board = require('firmata')

console.log("HI")
setTimeoutR = (t, fn) -> setTimeout(fn, t)

connected = false

plugs = new Board "/dev/cu.usbmodem14211", () ->
  console.log "Plug board connected"
  connected = true

  state = {}

  for i in [2...51] 
    do (i) ->
      plugs.pinMode(i, plugs.MODES.INPUT)
      plugs.digitalWrite(i, plugs.HIGH)

      plugs.digitalRead i, (val) ->
        if val != state[i]
          console.log "#{i}: #{val}"
          state[i] = val

# cables = new Board "/dev/cu.usbmodem14211", () ->
#   console.log "Cable board connected"

#   for i in [33...51]
#     cables.pinMode(i, board.MODES.OUTPUT) 

#   while true
#     cables.digitalWrite(i, cables.LOW)
