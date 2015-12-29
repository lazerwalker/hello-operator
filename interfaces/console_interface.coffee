_ = require 'underscore'

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

  initiateCall: (sender) ->
    console.log "#{sender} is calling!"

  askToConnect: ({sender, receiver}) ->
    console.log "Picked up #{sender}"
    console.log "\"Hey, it's #{sender}. Can I talk to #{receiver}?\""

  completeCall: ({sender, receiver}) ->
    console.log "#{sender} and #{receiver} finished talking."

  disconnectExisting: (caller) ->
    existing = _.filter @connected, (pair) -> caller in pair    
    console.log "Auto-Disconnected #{p[0]} and #{p[1]}" for p in existing    
    @connected = _.reject @connected, (pair) -> caller in pair

  updateHappiness: (call) ->
    state = @happiness[call.happiness]
    if call.receiver? 
      console.log "#{call.sender} and #{call.receiver} are #{state}"
    else
      console.log "#{call.sender} is #{state}"

  waitForInput: () ->
    process.stdin.resume();
    process.stdin.setEncoding('utf8');

    process.stdin.on 'data', (text) =>
      match = text.match /(\w+) (\w+)/
      [first, second] = [match[1], match[2]]

      if first is "me" or second is "me"
        other = if first is "me" then second else first
        if other in @connected
          console.log "Disconnected #{other} and operator"
          @client.disconnectOperator(other)
        else
          @disconnectExisting(other)
          console.log "Connected #{other} to operator"
          @connected.push [other, "me"]
          @client.connectOperator(other)
      else if first in @people and second in @people
        if _.find(@connected, (pair) -> first in pair and second in pair)
          console.log "Disconnected #{first} and #{second}."
          @client.disconnect(first, second)
        else
          @disconnectExisting(c) for c in [first, second]

          console.log "Connected #{first} and #{second}."
          @connected.push [first, second]
          @client.connect(first, second)

module.exports = ConsoleInterface