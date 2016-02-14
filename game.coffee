root = exports ? this
root._ = require('underscore') unless root._?

root.CablePair = require('./cablePair')
root.Call = require('./call')

setTimeoutR = (time, fn) -> setTimeout(fn, time)

###
Informal API

@protocol Client

function turnOnLight(caller)
function turnOffLight(caller)
function blinkLight({caller, rate}) // This is how it is because I don't know how to make JSCore accept multi-argument fns
function sayToConnect(call)

@end

@protocol Game

var client
var people

function connect(cable, caller)
function disconnect(cable, caller)
function toggleSwitch(cable, state) // state is -1, 0, or 1. Default is 0

@end

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

  numberOfConnections: 1

  # States are 0-5
  happinessStates: [
    { timeout: 2000, score: 10, rate: 0 },
    { timeout: 4000, score: 8, rate: 1000 },
    { timeout: 4000, score: 6, rate: 500 },
    { timeout: 4000, score: 3, rate: 200 },
    { score: 1, rate: 100 }
  ]

  
  ###
  # Public API
  ###

  constructor: ->
    @calls = []

    @cables = {}
    for i in [0..10]
      @cables[i] = new root.CablePair()


    @interfaces = []

    @startDate = new Date()

  addInterface: (i) ->
    i.people = @people
    i.client = @
    @interfaces.push i

  startGame: ->
    @addNewCall()

    # for i in [15, 60, 120, 150]
    #   setTimeout ( () => @addNewCall() ), i * 1000 

  ###
  # Interface methods
  ###  
  connect: (cableString, caller) =>
    [cableNumber, isFront] = @parseCableString(cableString)
    cable = @cables[cableNumber]

    if isFront
      cable.front = caller
      call = root._(@calls).findWhere {receiver: cable.front}
    else
      cable.rear = caller
      call = root._(@calls).findWhere {sender: cable.rear}
  
    # Check state
    if call?.checkState(cable)
      @updateCall(call)

  disconnect: (first, second) =>

  toggleSwitch: (cableString, state) =>
    [cableNumber, isFront] = @parseCableString(cableString)
    cable = @cables[cableNumber]

    if isFront
      cable.frontSwitch = state
    else
      cable.rearSwitch = state

    call = root._(@calls).findWhere {sender: cable.rear}
    if call?.checkState(cable)
      @updateCall(call)

  ###
  # Deprecated
  ###

  connectOperator: (caller) =>
    call = root._(@calls).findWhere {sender: caller}
    return unless call
    return if call.connected
    call.shouldIgnoreHappiness = true
    call.pickedUp = true
    for i in @interfaces
      i.turnOnLight(call.sender) # Make their light solid, if blinking
      i.sayToConnect(call) 

  disconnectOperator: (caller) =>

  ###
  # Private
  ###

  updateCall: (call) ->
    # Each block in here runs when we're transitioning to that state
    switch call.state
      when root.Call.State.WaitingToConnect
        call.shouldIgnoreHappiness = true
        for i in @interfaces
          i.turnOnLight(call.sender) # Make their light solid, if blinking
          i.sayToConnect(call) 
      when root.Call.State.Ringing
        # TODO: pretty ring blinking?
        rand = root._.random(1000, 3000) # TODO: Better rand
        setTimeoutR rand, =>
          call.receiverPickedUp = true
          # TODO: Whoo-ey, get a whiff of this code smell!          
          @updateCall(call) if (call.checkState(call.cable))
      when root.Call.State.PickedUp
        for i in @interfaces
          i.turnOnLight(call.receiver)

        rand = @timeWeightedRand(1000, 7000)
        setTimeoutR rand, =>
          call.hungUp = true
          @updateCall(call) if (call.checkState(call.cable))
      when root.Call.State.Done
        for i in @interfaces
          i.turnOffLight(call.sender)
          i.turnOffLight(call.receiver)          

        # TODO: Logic for starting a new call

  parseCableString: (cableString) -> [cableString[5], cableString[6] is "F"]

  timeWeightedRand: (low, high) ->
    diff = (new Date() - @startDate) / 1000
    rand = root._.random(low, high)
    return rand * (1 - diff/300)

  endCall: (call) =>
    call.sender.busy = false
    call.receiver.busy = false
    call.shouldIgnoreHappiness = true

    for i in @interfaces
      i.turnOffLight(call.sender) 
      i.turnOffLight(call.receiver)

    @calls = root._(@calls).without(call)

    wait = @timeWeightedRand(1000, 7000)
    setTimeout (() => @addNewCall()), wait

  addNewCall: =>
    [first, second] = root._(@people).chain()
      .reject (p) -> p.busy
      .sample(2)
      .value()

    return unless first and second

    call = new root.Call(first, second)

    @calls.push(call)
    i.turnOnLight(call.sender) for i in @interfaces

    @updateHappiness(call)

  # TODO: Push this into the object
  updateHappiness: (call) =>
    return if call.shouldIgnoreHappiness
    return if call.happiness >= call.happiness.length

    call.happiness = call.happiness + 1
    happiness = @happinessStates[call.happiness]

    callObj = Object.assign({}, call)
    if !call.pickedUp
      delete callObj.receiver

    for i in @interfaces
      i.blinkLight({caller: callObj.sender, rate: happiness.rate})
      i.blinkLight({caller: callObj.sender, rate: happiness.rate}) if callObj.receiver?

    if happiness.timeout?
      call.timer = setTimeout ( () => @updateHappiness(call) ), happiness.timeout

if module?.exports
  module.exports = Game
else if exports?
    exports = Game
else
  @Game = Game