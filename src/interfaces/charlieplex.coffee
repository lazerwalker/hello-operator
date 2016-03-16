Gpio = require('onoff').Gpio
_ = require 'underscore'

pinNums = [17, 27, 16, 20]
pins = _(pinNums).map (pin) -> new Gpio(pin, 'in')

ledNums = [ [17, 27], [17, 20], [27, 17], [16, 27] ]
leds = _(ledNums).map ([first, second]) ->
  firstIndex = _.indexOf(pinNums, first)
  secondIndex = _.indexOf(pinNums, second)
  [pins[firstIndex], pins[secondIndex]]

charlieplex = ([anode, cathode]) ->
  pin.setDirection('in') for pin in pins
  anode.setDirection 'high'
  cathode.setDirection 'low'

iter = (i) ->
  led = leds[i]
  unless led?
    iter(0)
    return

  console.log "Charlieplexing led #{i} (#{led})"
  charlieplex(led)
  setTimeout (() -> iter(i+1)), 1000

iter(0)


