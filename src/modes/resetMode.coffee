Q = require('q')
_ = require('underscore')

SwitchState = require('../cablePair').SwitchState

class ResetMode
  constructor: (@game) ->

  start: ->
    console.log "Starting rest"
  stop: ->

  connect: (cable, isFront, caller) ->

  disconnect: (cable, isFront, caller) ->

  toggleSwitch: (cable, isFront, state) ->
    if isFront
      cable.frontSwitch = state
    else
      cable.rearSwitch = state

    # Don't reset the game until all the switches are back to normal
    if _.chain(@game.cables)
      .pluck("frontSwitch")
      .reduce( ((memo, val) -> memo and (val is SwitchState.Neutral)), true)
      .value()
        @game.nextMode()


module.exports = ResetMode