fs = require('fs')
_ = require('underscore')

SwitchState = require('../src/cablePair').SwitchState

class Calibration
  constructor: (file) ->
    file ?= "#{__dirname}/latestCalibration.json"
    console.log(file)
    @mapping = JSON.parse fs.readFileSync(file)

  cablePinFromNum: (num) -> parseInt(@mapping.cables[num])
  cableNumFromPin: (pin) -> parseInt(_.invert(@mapping.cables)[pin])

  portPinFromNum: (num) -> parseInt(@mapping.ports[num])
  portNumFromPin: (pin) -> parseInt(_.invert(@mapping.ports)[pin])

  cableLightPinFromNum: (num) -> @mapping.cableLights[num]
  cableLightNumFromPin: (pin) -> _.invert(@mapping.cableLights)[pin]  

  portLightPinFromNum: (num) -> parseInt(@mapping.portLights[num])
  portLightNumFromPin: (pin) -> parseInt(_.invert(@mapping.portLights)[pin])

  switchPinFromNum: (num) -> @mapping.switches[num] # TODO: Fix this

  switchNumFromPin: (pin) -> 
    result = _.chain(@mapping.switches)
      .pairs()
      .find( (obj) -> obj[1].talk is pin || obj[1].ring is pin )
      .value()

    if result
      position = if result[1].talk is pin then SwitchState.Talk else SwitchState.Ring
      return {switchNum: result[0], position}

module.exports = Calibration