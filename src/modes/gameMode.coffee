_ = require('underscore')

Call = require('../call')

setTimeoutR = (time, fn) -> setTimeout(fn, time)

class GameMode
  happinessStates: [
    { timeout: 2000, score: 10, rate: 0 },
    { timeout: 4000, score: 8, rate: 1000 },
    { timeout: 4000, score: 6, rate: 500 },
    { timeout: 4000, score: 3, rate: 200 },
    { score: 1, rate: 100 }
  ]

  constructor: (@game) ->
    @calls = []

  start: ->
    @startDate = new Date()
    @running = true
    @addNewCall()

    for i in [30, 120]
      setTimeout ( () => @addNewCall() ), i * 1000 

  stop: ->
    @running = false
    @calls = []

  connect: (cable, isFront, caller, callingInterface) ->
   
    if isFront
      cable.front = caller
      call = _(@calls).findWhere {receiver: cable.front}
    else
      cable.rear = caller
      call = _(@calls).findWhere {sender: cable.rear}
  
    # Check state
    if call?.checkState(cable, @cables)
      @updateCall(call)

  disconnect: (cable, isFront, caller, callingInterface) ->

  toggleSwitch: (cable, isFront, state, callingInterface) ->
    _(@interfaces).chain()
      .without(callingInterface)
      .each ( (i) -> i.didToggleSwitch?(cableString, state) )

    if isFront
      cable.frontSwitch = state
    else
      cable.rearSwitch = state

    call = _(@calls).findWhere {sender: cable.rear}

    if call?.checkState(cable, @cables)
      @updateCall(call)
      return true
    else 
      return false

  ###
  # Private
  ###
  addNewCall: =>
    return unless @running
    [first, second] = _(@game.people).chain()
      .reject (p) -> p.busy
      .sample(2)
      .value()

    return unless first and second

    call = new Call(first, second)

    @calls.push(call)
    i.turnOnLight(call.sender) for i in @game.interfaces

    @updateHappiness(call)

  # TODO: Push this into the object
  updateHappiness: (call) =>
    return unless @running
    return if call.shouldIgnoreHappiness
    return if call.happiness >= call.happiness.length

    call.happiness = call.happiness + 1
    happiness = @happinessStates[call.happiness]

    callObj = _.extend({}, call)
    if !call.pickedUp
      delete callObj.receiver

    for i in @game.interfaces
      i.blinkLight({caller: callObj.sender, rate: happiness.rate})
      i.blinkLight({caller: callObj.sender, rate: happiness.rate}) if callObj.receiver?

    if happiness.timeout?
      call.timer = setTimeout ( () => @updateHappiness(call) ), happiness.timeout

  updateCall: (call) ->
    # Each block in here runs when we're transitioning to that state
    switch call.state
      when Call.State.WaitingToTalk
        for i in @game.interfaces
          i.turnOnLight(call.cable.rearLight)
      when Call.State.WaitingToConnect
        call.shouldIgnoreHappiness = true
        for i in @game.interfaces
          i.turnOffLight(call.sender)
          i.turnOnLight(call.cable.rearLight)
          i.sayToConnect(call)
      when Call.State.Ringing
        for i in @game.interfaces
          i.blinkLight({caller: call.cable.frontLight, rate: 400})
        rand = _.random(1000, 3000) # TODO: Better rand
        setTimeoutR rand, =>
          call.receiverPickedUp = true
          # TODO: Whoo-ey, get a whiff of this code smell!          
          @updateCall(call) if (call.checkState(call.cable, @cables))
      when Call.State.PickedUp
        for i in @game.interfaces
          i.turnOnLight(call.cable.frontLight)

        rand = @timeWeightedRand(2000, 9000)
        setTimeoutR rand, =>
          call.hungUp = true
          @updateCall(call) if (call.checkState(call.cable, @cables))
      when Call.State.Done
        for i in @game.interfaces
          i.turnOffLight(call.cable.frontLight)
          i.turnOffLight(call.cable.rearLight)         

        @calls = _(@calls).without(call)
        call.tearDown()

        # TODO: When this gets more complicated, extract this out.
        wait = @timeWeightedRand(1000, 7000)
        setTimeout (() => @addNewCall()), wait

  timeWeightedRand: (low, high) ->
    diff = (new Date() - @startDate) / 1000
    rand = _.random(low, high)
    return rand * (1 - diff/300)        
module.exports = GameMode