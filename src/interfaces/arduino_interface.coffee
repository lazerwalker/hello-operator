_ = require 'underscore'
exec = require('child_process').exec;

ArduinoGroup = require('../../arduino/arduino_group')
SwitchState = require('../cablePair').SwitchState

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class ArduinoInterface
  constructor: (@people, @client, ports=[]) ->
    @arduino = new ArduinoGroup(ports)
    @blinkTimers = {}
    @blinkState = {}

    @arduino.on 'connect', ({cable, port}) ->
      cableName = "cable#{cable}"
      portName = @people[port]
      @client.connect(cableName, portName)

    @arduino.on 'disconnect', ({cable, port}) ->
      cableName = "cable#{cable}"
      portName = @people[port]
      @client.disconnect(cableName, portName)

    @arduino.on 'toggleSwitch', ({theSwitch, position}) ->
      switchName = "switch#{theSwitch}"
      @client.toggleSwitch(switchName, position)

  turnOnLight: (caller, blink = false) ->
    if !blink and @blinkTimers[caller]?
      clearTimeout @blinkTimers[caller] 

    callerNum = _.indexOf @people, caller
    @arduino.turnOnLight(callerNum)

  turnOffLight: (caller, blink = false) ->
    if !blink and @blinkTimers[caller]?
      clearTimeout @blinkTimers[caller] 
   
    callerNum = _.indexOf @people, caller
    @arduino.turnOffLight(callerNum)

  blinkLight: ({caller, rate}) ->
    clearTimeout @blinkTimers[caller] if @blinkTimers[caller]?

    if @blinkState[caller]
      @turnOnLight(caller, true)
      @blinkState = false
    else
      @turnOffLight(caller, true)
      @blinkState = true

    callerNum = _.indexOf @people, caller
    @blinkTimers[caller] = setTimeoutR rate, ( => @blink({caller, rate}) )

  sayToConnect: ({sender, receiver}) ->
    console.log "Picked up #{sender}"
    speak "\"Hey, it's #{sender}. Can I talk to #{receiver}?\""

  speak: (sentence) ->
    # TODO: This will only work on OS X
    console.log sentence
    exec("say \"#{sentence}\"")

module.exports = ArduinoInterface