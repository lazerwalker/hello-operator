_ = require "underscore"
exec = require('child_process').exec

ConsoleInterface = require './interfaces/console_interface'

people = [
  "1A"
  "1B"
  "1C"
  "1D"
  "1E"
  "2A"
  "2B"
  "2C"
  "2D"
  "2E"
]

# Game
calls = []
interfaces = []


connectOperator = (caller) ->
  call = _(calls).findWhere {sender: caller}
  return unless call
  return if call.pickedUp

  call.pickedUp = true

  i.askToConnect(call) for i in interfaces

disconnectOperator = (caller) ->

connect = (first, second) ->
  call = _(calls).findWhere {sender: first, receiver: second}
  unless call
    call = _(calls).findWhere {sender: second, receiver: first}
  return unless call and call.pickedUp

  i.completeCall(call) for i in interfaces

  first.busy = false
  second.busy = false

  calls = _(calls).without(call)
  addNewCall()

disconnect = (first, second) ->


addNewCall = ->
  [first, second] = _(people).chain()
    .reject (p) -> p.busy
    .sample(2)
    .value()

  return unless first and second

  instruction =
    sender: first,
    receiver: second

  first.busy = true
  second.busy = true

  calls.push(instruction)



  i.initiateCall(instruction.sender) for i in interfaces

client = {connect, disconnect, connectOperator, disconnectOperator}
interfaces.push new ConsoleInterface(people, client)
addNewCall()