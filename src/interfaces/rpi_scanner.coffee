Gpio = require('onoff').Gpio
_ = require 'underscore'

NOT_CONNECTED = -1

pinNums = JSON.parse process.argv[2]
console.log pinNums
pins = _(pinNums).map (pin) -> new Gpio(pin, 'in')
state = pinNums.map -> NOT_CONNECTED

unless process.send?
  console.log "This isn't a child process!"

send = (isOn, i, j) ->
  json = { type: (if isOn then "on" else "off"), pins: [pinNums[i], pinNums[j]] }
  if process.send?
    process.send json
  else
    console.log JSON.stringify(json)
 

sendConnected = (i, j) -> send(true, i, j)
sendDisconnected = (i, j) -> send(false, i, j)

while true
  for pin, i in pins
    pin.setDirection('high')

    for pin2, j in pins
      continue if pin is pin2  

      val = pin2.readSync()
      if val
        if state[j] is NOT_CONNECTED
          sendConnected(i, j)
        state[i] = j
        state[j] = i
      else
        if state[j] is i and state[i] is j
          sendDisconnected(i, j)
          state[i] = NOT_CONNECTED
          state[j] = NOT_CONNECTED
    pin.setDirection('in')

