_ = require 'underscore'
SwitchState = require('./cablePair').SwitchState

State = 
  Unstarted: 0
  WaitingToTalk: 1
  WaitingToConnect: 2
  Ringing: 3
  PickedUp: 4
  Done: 5


class Call
  constructor: (@sender, @receiver) ->
    @state = State.Unstarted
    @happiness = -1

    @receiverPickedUp = false
    @hungUp = false

    @sender.busy = true
    @receiver.busy = true


  tearDown: ->
    @sender.busy = false
    @receiver.busy = false

  checkState: (cable, cables) ->
    rearIsConnected = cable?.rear? and cable.rear is @sender
    frontIsConnected = cable?.front? and cable.front is @receiver

    if cable?
      @cable = cable

    changeState = false
    switch @state
      when State.Unstarted
        changeState = rearIsConnected
      when State.WaitingToTalk
        changeState = rearIsConnected and cable.rearSwitch is SwitchState.Talk
      when State.WaitingToConnect
        changeState = rearIsConnected and frontIsConnected and 
          cable.frontSwitch isnt SwitchState.Neutral
      when State.Ringing
        changeState = !!@receiverPickedUp
      when State.PickedUp
        changeState = !!@hungUp
      # Don't need to worry about the "Done" state

    @state++ if changeState

    return changeState

Call.State = State


module.exports = Call