_ = require "underscore"
exec = require('child_process').exec

people = [
  {pin: 3, name: "1A"},
  {pin: 4, name: "1B"},
  {pin: 5, name: "1C"},
  {pin: 6, name: "1D"},
  {pin: 7, name: "1E"},
  {pin: 8, name: "2A"},
  {pin: 9, name: "2B"},
  {pin: 10, name: "2C"},
  {pin: 11, name: "2D"},
  {pin: 12, name: "2E"},
]

# Game
calls = []

ledOn = (person) ->
  return unless USE_OUTPUT
  output.write "#{person.pin}"

ledOff = (person) ->
  return unless USE_OUTPUT
  output.write "-#{person.pin}"

pickUpPhone = (caller) ->
  call = _(calls).findWhere {sender: caller}
  return unless call
  return if call.pickedUp

  ledOff(call.sender)
  call.pickedUp = true

  console.log "Picked up #{call.sender.name}"
  exec "afplay audio/a1.aiff"
  console.log "\"Hey, it's #{call.sender.name}. Can I talk to #{call.recipient.name}?\""

match = (callers) ->
  first = callers[0]
  second = callers[1]

  call = _(calls).findWhere {sender: first, recipient: second}
  unless call
    call = _(calls).findWhere {sender: second, recipient: first}
  return unless call and call.pickedUp

  console.log "Yay!"

  first.busy = false
  second.busy = false

  calls = _(calls).without(call)
  addNewCall()

addNewCall = ->
  [first, second] = _(people).chain()
    .reject((p) -> p.busy)
    .sample(2)
    .value()

  return unless first and second

  instruction = {
    sender: first,
    recipient: second
  }

  first.busy = true
  second.busy = true

  calls.push(instruction)
  console.log "#{instruction.sender.name} is calling!"

  ledOn(instruction.sender)


else
  addNewCall()