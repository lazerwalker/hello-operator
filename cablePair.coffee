SwitchState = 
  Talk: -1
  Neutral: 0
  Ring: 1

class CablePair
  constructor: ->
    @front = undefined
    @rear = undefined

    @frontSwitch = SwitchState.Neutral
    @rearSwitch = SwitchState.Neutral

CablePair.SwitchState = SwitchState

module.exports = CablePair