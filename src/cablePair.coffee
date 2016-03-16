SwitchState = 
  Talk: -1
  Neutral: 0
  Ring: 1

class CablePair
  constructor: (@number) ->
    @front = undefined
    @rear = undefined

    @frontSwitch = SwitchState.Neutral
    @rearSwitch = SwitchState.Neutral

    @frontLight = "cable#{@number}F"
    @rearLight = "cable#{@number}R"

CablePair.SwitchState = SwitchState

module.exports = CablePair