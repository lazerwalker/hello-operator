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

  numberOfConnections: 2

  # States are 0-5
  happinessStates: [
    { timeout: 2000, score: 10 },
    { timeout: 4000, score: 8 },
    { timeout: 4000, score: 6 },
    { timeout: 4000, score: 3 },
    { score: 1 }
  ]

  constructor: ->
    @calls = []
    @interfaces = []

    @startDate = new Date()

  timeWeightedRand: (low, high) ->
    diff = (new Date() - @startDate) / 1000
    rand = root._.random(low, high)
    return rand * (1 - diff/300)

  connectOperator: (caller) =>
    call = root._(@calls).findWhere {sender: caller}

    return unless call
    return if call.pickedUp
    call.shouldIgnoreHappiness = true
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
    timeout = @timeWeightedRand(1000, 5000)
    setTimeout ( () => @askToEndCall(call) ), timeout

  disconnect: (first, second) =>
    call = root._(@calls).findWhere {sender: first, receiver: second}
    unless call
      call = root._(@calls).findWhere {sender: second, receiver: first}
    return unless call?.waitingToDisconnect

    first.busy = false
    second.busy = false
    call.shouldIgnoreHappiness = true

    i.completeCall(call) for i in @interfaces

    @calls = root._(@calls).without(call)

  addNewCall: =>
    [first, second] = root._(@people).chain()
      .reject (p) -> p.busy
      .sample(2)
      .value()

    return unless first and second

    call =
      sender: first,
      receiver: second
      happiness: -1

    first.busy = true
    second.busy = true

    @calls.push(call)
    i.initiateCall(call.sender) for i in @interfaces

    @updateHappiness(call)

  addInterface: (i) ->
    i.people = @people
    i.client = @
    @interfaces.push i

  startGame: ->
    timeout = 0
    for i in [0...@numberOfConnections]
      setTimeout @addNewCall, timeout
      timeout += @timeWeightedRand(500, 5000)

  askToEndCall: (call) =>
    return unless call.connected

    call.waitingToDisconnect = true
    call.shouldIgnoreHappiness = false
    call.happiness = -1
    @updateHappiness(call)

    i.askToDisconnect(call) for i in @interfaces

    wait = @timeWeightedRand(1000, 7000)
    setTimeout (() => @addNewCall()), wait

  updateHappiness: (call) =>
    return if call.shouldIgnoreHappiness
    return if call.happiness >= call.happiness.length

    call.happiness = call.happiness + 1
    happiness = @happinessStates[call.happiness]

    callObj = Object.assign({}, call)
    if !call.pickedUp
      delete callObj.receiver

    i.updateHappiness(callObj) for i in @interfaces

    if happiness.timeout?
      call.timer = setTimeout ( () => @updateHappiness(call) ), happiness.timeout

if module?.exports
  module.exports = Game
else if exports?
    exports = Game
else
  @Game = Game