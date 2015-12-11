Gpio = require('onoff').gpio

people =
  "1A":
    led: 12
  "1B":
    led: 24
  "1C":
    led: 23
  "1D":
    led: 18

class RpiInterface
  initialize: ->
    @people = people.map (p) ->
      p.led = new Gpio(p.led, 'out')
      p

  initiateCall: (sender) ->
    console.log "SENDER", sender
    pin = @people[sender].led
    console.log "Initiating call with sender #{sender}"
    pin.write(true)




module.exports = RpiInterface
