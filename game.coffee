root = exports ? this
root._ = require('underscore') unless root._?
  

### Client
askToConnect(call)
askToDisconnect(call)
initiateCall(sender)
completeCall(call)

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
    "Dolores"
    "Mabel"
    "Irene"
    "Evelyn"
    "Gladys"
    "Ethel"
    "Bernice"
    "Lucille"
    "Edith"
    "Rita"
    "Mae"
    "Rosemary"
    "Beverly"
    "Pearl"
    "Vera"
    "Joyce"
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

    call.connected = true

    # Set timer to start the disconnect
    # TODO: When this gets more complicated, extract this out.
    timeout = root._.random(10, 50) * 100
    setTimeout ( () => @askToEndCall(call) ), timeout

  disconnect: (first, second) =>
    call = root._(@calls).findWhere {sender: first, receiver: second}
    unless call
      call = root._(@calls).findWhere {sender: second, receiver: first}
    return unless call?.waitingToDisconnect

    first.busy = false
    second.busy = false

    i.completeCall(call) for i in @interfaces

    @calls = root._(@calls).without(call)
    @addNewCall()

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

  askToEndCall: (call) =>
    return unless call.connected

    call.waitingToDisconnect = true
    i.askToDisconnect(call) for i in @interfaces


if module?.exports
  module.exports = Game
else if exports?
    exports = Game
else
  @Game = Game