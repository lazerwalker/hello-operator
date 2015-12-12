root = exports ? this
root._ = require('underscore') unless root._?
  

### Client
askToConnect(call)
completeCall(call)
initiateCall(sender)

client
people

Expected to call:
connect
disconnect
connectOperator (deprecate)
disconnectOperator (deprecate)
###

class Game
  people: [
    "1A"
    "1B"
    "1C"
    "1D"
    "2A"
    "2B"
    "2C"
    "2D"
  ]
  constructor: ->
    @calls = []
    @interfaces = []

  connectOperator: (caller) =>
    call = root._(@calls).findWhere {sender: caller}

    return unless call
    return if call.pickedUp
    call.pickedUp = true
    i.askToConnect(call) for i in @interfaces

  disconnectOperator: (caller) =>

  connect: (first, second) =>
    call = root._(@calls).findWhere {sender: first, receiver: second}
    unless call
      call = root._(@calls).findWhere {sender: second, receiver: first}
    return unless call and call.pickedUp

    i.completeCall(call) for i in @interfaces

    first.busy = false
    second.busy = false

    @calls = root._(@calls).without(call)
    @addNewCall()

  disconnect: (first, second) =>

  addNewCall: =>
    [first, second] = root._(@people).chain()
      .reject (p) -> p.busy
      .sample(2)
      .value()

    return unless first and second

    instruction =
      sender: first,
      receiver: second

    first.busy = true
    second.busy = true

    @calls.push(instruction)
    i.initiateCall(instruction.sender) for i in @interfaces

  addInterface: (i) ->
    i.people = @people
    i.client = @
    @interfaces.push i

  startGame: ->
    @addNewCall()

if module?.exports
  module.exports = Game
else if exports?
    exports = Game
else
  @Game = Game