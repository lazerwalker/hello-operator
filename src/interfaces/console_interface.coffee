_ = require 'underscore'
Q = require 'q'

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
    Q()

  turnOffLight: (caller) ->
    console.log "#{caller} is OFF"
    Q()

  blinkLight: ({caller, rate}) ->
    console.log "#{caller} is BLINKING at #{rate}"
    Q()

  sayToConnect: ({sender, receiver}) ->
    console.log "Picked up #{sender}"
    console.log "\"Hey, it's #{sender}. Can I talk to #{receiver}?\""
    Q()

  sayText: (identifier, text) ->
    console.log "#{identifier}: \"#{text}\""
    Q()

  disconnectExisting: (caller) ->
    existing = _.filter @connected, (pair) -> caller in pair    
    console.log "Auto-Disconnected #{p[0]} and #{p[1]}" for p in existing    
    @connected = _.reject @connected, (pair) -> caller in pair

  # -

  didConnect: (first, second) ->
    console.log "Connected #{first} and #{second}"

  didDisconnect: (first, second) ->
    console.log "Disconnected #{first} and #{second}"

  didToggleSwitch: (cable, position) ->
    mapping = 
      "-1": "talk",
      "0": "neutral",
      "1": "ring"
    console.log "Switched #{cable} to #{mapping[position]}"

  # -

  waitForInput: () ->
    process.stdin.resume();
    process.stdin.setEncoding('utf8');

    process.stdin.on 'data', (text) =>
      if text is "reset1\n"
        for i in [0...10]
          @client.toggleSwitch("cable#{i}F", SwitchState.Talk, this)
        return
      if text is "reset2\n"
        for i in [0...10]
          @client.toggleSwitch("cable#{i}F", SwitchState.Neutral, this)
        return

      match = text.match /(\w+) (\w+)/
      [first, second] = [match[1], match[2]]

      # TODO: regex match
      first = "cable#{first.toUpperCase()}"

      if second in ["r", "n", "t"]
        mapping = 
          r: SwitchState.Ring,
          n: SwitchState.Neutral,
          t: SwitchState.Talk

        console.log("Toggling switch", first, mapping[second])
        @client.toggleSwitch(first, mapping[second], this)
        return

      if second is "m"
        second = "Mabel"
      if second is "d"
        second = "Dolores"

      if (found = _.find(@connected, (pair) -> first in pair and second in pair))
        console.log "Disconnected #{first} and #{second}."
        @connected = _.without(@connected, found)
        @client.disconnect(first, second, this)
      else
        @disconnectExisting(c) for c in [first, second]

        console.log "Connected #{first} and #{second}."
        @connected.push [first, second]
        @client.connect(first, second, this)

module.exports = ConsoleInterface