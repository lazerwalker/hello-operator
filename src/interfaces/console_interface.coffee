_ = require 'underscore'
SwitchState = require('../cablePair').SwitchState

class ConsoleInterface
  happiness: [
    "happily waiting"
    "still pretty satisfied"
    "starting to get impatient"
    "rather annoyed"
    "livid"
  ]

  constructor: (@people, @client) ->
    @connected = []
    @waitForInput()

  onReady: (cb) ->
    cb()

  turnOnLight: (caller) ->
    console.log "#{caller} is ON"

  turnOffLight: (caller) ->
    console.log "#{caller} is OFF"

  blinkLight: ({caller, rate}) ->
    console.log "#{caller} is BLINKING at #{rate}"

  sayToConnect: ({sender, receiver}) ->
    console.log "Picked up #{sender}"
    console.log "\"Hey, it's #{sender}. Can I talk to #{receiver}?\""

  disconnectExisting: (caller) ->
    existing = _.filter @connected, (pair) -> caller in pair    
    console.log "Auto-Disconnected #{p[0]} and #{p[1]}" for p in existing    
    @connected = _.reject @connected, (pair) -> caller in pair

  waitForInput: () ->
    process.stdin.resume();
    process.stdin.setEncoding('utf8');

    process.stdin.on 'data', (text) =>
      match = text.match /(\w+) (\w+)/
      [first, second] = [match[1], match[2]]

      if second in ["ring", "neutral", "talk"]
        mapping = 
          ring: SwitchState.Ring,
          neutral: SwitchState.Neutral,
          talk: SwitchState.Talk

        console.log("Toggling switch", first, mapping[second])
        @client.toggleSwitch(first, mapping[second])
      else if _.find(@connected, (pair) -> first in pair and second in pair)
        console.log "Disconnected #{first} and #{second}."
        @client.disconnect(first, second)
      else
        @disconnectExisting(c) for c in [first, second]

        console.log "Connected #{first} and #{second}."
        @connected.push [first, second]
        @client.connect(first, second)

module.exports = ConsoleInterface