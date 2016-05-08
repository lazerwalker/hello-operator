_ = require('underscore')

Call = require('../call')
SwitchState = require('../cablePair').SwitchState

setTimeoutR = (time, fn) -> setTimeout(fn, time)

class GameMode
  namesToIgnore: ["Mae", "Clarence"]
  allowAutoReset: true

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

  connect: (cable, isFront, caller) ->
   
    if isFront
      cable.front = caller
      call = _(@calls).findWhere {receiver: cable.front}
    else
      cable.rear = caller
      call = _(@calls).findWhere {sender: cable.rear}
  
    # Check state
    if call?.checkState(cable, @cables)
      @updateCall(call)

  disconnect: (cable, isFront, caller) ->

  toggleSwitch: (cable, isFront, state) ->
    if isFront
      cable.frontSwitch = state
    else
      cable.rearSwitch = state

    call = _(@calls).findWhere {sender: cable.rear}

    if call?.checkState(cable, @cables)
      @updateCall(call)
      return true
    else 
      # Re-play Talk if appropriate
      if call?.state is Call.State.WaitingToConnect and cable.rearSwitch is SwitchState.Talk and !isFront
        @game.sayToConnect(call)

      # RESET THE GAME by flipping all front switches to talk
      if _.chain(@game.cables)
        .pluck("rearSwitch")
        .reduce( ((memo, val) -> memo and (val is SwitchState.Talk)), true)
        .value()
          @game.nextMode()

  ###
  # Private
  ###
  addNewCall: =>
    return unless @running
    [first, second] = _(@game.people).chain()
      .reject (p) -> p.busy
      .reject (p) => p in @namesToIgnore
      .sample(2)
      .value()

    # Don't start a call where the first caller is currently connected
    # (and thus won't light up)
    # FIXME: There's a better way to handle this properly than just re-rolling the dice.
    if @game.connected[first]
      return @addNewCall()

    return unless first and second

    call = new Call(first, second)

    @calls.push(call)
    @game.turnOnLight(call.sender)

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

    @game.blinkLight({caller: callObj.sender, rate: happiness.rate})
    @game.blinkLight({caller: callObj.sender, rate: happiness.rate}) if callObj.receiver?

    if happiness.timeout?
      call.timer = setTimeout ( () => @updateHappiness(call) ), happiness.timeout

  updateCall: (call) ->
    # Each block in here runs when we're transitioning to that state
    switch call.state
      when Call.State.WaitingToTalk
        @game.turnOnLight(call.cable.rearLight)
      when Call.State.WaitingToConnect
        call.shouldIgnoreHappiness = true
        @game.turnOffLight(call.sender)
        @game.turnOnLight(call.cable.rearLight)
        @game.sayToConnect(call)
      when Call.State.Ringing
        @game.blinkLight({caller: call.cable.frontLight, rate: 400})
        rand = _.random(1000, 3000) # TODO: Better rand
        setTimeoutR rand, =>
          call.receiverPickedUp = true
          # TODO: Whoo-ey, get a whiff of this code smell!          
          @updateCall(call) if (call.checkState(call.cable, @cables))
      when Call.State.PickedUp
        @game.turnOnLight(call.cable.frontLight)

        rand = @timeWeightedRand(2000, 9000)
        setTimeoutR rand, =>
          call.hungUp = true
          @updateCall(call) if (call.checkState(call.cable, @cables))
      when Call.State.Done
        @game.turnOffLight(call.cable.frontLight)
        @game.turnOffLight(call.cable.rearLight)         

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