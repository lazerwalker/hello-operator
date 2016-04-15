Q = require('q')
_ = require('underscore')

SwitchState = require('../cablePair').SwitchState

class SilentMode
  constructor: (@game) ->

  start: ->

  stop: ->

  connect: (cable, isFront, caller) ->

  disconnect: (cable, isFront, caller) ->

  toggleSwitch: (cable, isFront, state) ->
    @game.nextMode()
    return true


module.exports = SilentMode