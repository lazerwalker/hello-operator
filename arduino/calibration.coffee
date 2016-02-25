fs = require('fs')
SwitchState = require('../src/cablePair').SwitchState

class Calibration
  constructor: (file) ->
    file ?= "#{__dirname}/latestCalibration.json"
    console.log(file)
    @mapping = JSON.parse fs.readFileSync(file)

  cablePinFromNum: (num) -> @mapping.cables[num]
  cableNumFromPin: (pin) -> _.invert(@mapping.cables)[pin]

  portPinFromNum: (num) -> @mapping.ports[num]
  portNumFromPin: (pin) -> _.invert(@mapping.ports)[pin]

  cableLightPinFromNum: (num) -> @mapping.cableLights[num]
  cableLightNumFromPin: (pin) -> _.invert(@mapping.cableLights)[pin]  

  portLightPinFromNum: (num) -> @mapping.portLights[num]
  portLightNumFromPin: (pin) -> _.invert(@mapping.portLights)[pin]

  switchPinFromNum: (num) -> @mapping.switches[num] # TODO: Fix this

  switchNumFromPin: (pin) -> 
    result = _.chain(@mapping.switches)
      .pairs()
      .find( (obj) -> obj[1].talk is pin || obj[1].ring is pin )
      .value()

    if result
      position = if obj[1].talk is pin then SwitchState.TALK else SwitchState.RING
      return {switchNum: result[0], position}

module.exports = Calibration