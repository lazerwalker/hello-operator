SwitchState = require('./cablePair').SwitchState

State = 
  Unstarted: 0
  WaitingToConnect: 1
  Ringing: 2
  PickedUp: 3
  Done: 4


class Call
  constructor: (@sender, @receiver) ->
    @state = State.Unstarted
    @happiness = -1

    @receiverPickedUp = false
    @hungUp = false

    @sender.busy = true
    @receiver.busy = true


  checkState: (cable) ->
    rearIsConnected = cable?.rear? and cable.rear is @sender
    frontIsConnected = cable?.front? and cable.front is @receiver

    if cable?
      @cable = cable

    changeState = false
    switch @state
      when State.Unstarted
        changeState = rearIsConnected and cable.rearSwitch is SwitchState.Talk
      when State.WaitingToConnect
        changeState = rearIsConnected and frontIsConnected and cable.frontSwitch is SwitchState.Ring
      when State.Ringing
        changeState = !!@receiverPickedUp
      when State.PickedUp
        changeState = !!@hungUp
      # Don't need to worry about the "Done" state

    @state++ if changeState

    return changeState

Call.State = State


module.exports = Call