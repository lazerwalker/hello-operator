_ = require 'underscore'
spawn = require('child_process').spawn;
sfx = require('sfx')
Q = require('q')

ArduinoGroup = require('../../arduino/arduino_group')
SwitchState = require('../cablePair').SwitchState

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class ArduinoInterface
  constructor: (ports=[], fake = false) ->
    @people = []
    @client = []

    if fake
      @arduino = {
        on: (event, cb) ->
          cb({})
        turnOnLight: ->
        turnOffLight: ->
      }
    else
      @arduino = new ArduinoGroup(ports)

    @blinkTimers = {}
    @blinkState = {}

    @arduino.on 'connect', ({cable, port}) =>
      cableName = "cable#{cable}"
      portName = @people[port - 1]
      console.log "Connecting #{cableName}, #{portName}" if @debug
      @client?.connect?(cableName, portName, this)

    @arduino.on 'disconnect', ({cable, port}) =>
      cableName = "cable#{cable}"
      portName = @people[port - 1]
      @client?.disconnect?(cableName, portName, this)

    @arduino.on 'toggleSwitch', ({switchNum, position}) =>
      switchName = "cable#{switchNum}"
      @client?.toggleSwitch?(switchName, position, this)

  turnOnLight: (caller, blink = false) ->
    if !blink and @blinkTimers[caller]?
      clearTimeout @blinkTimers[caller] 

    if caller in @people
      callerNum = (_.indexOf @people, caller) + 1
      @arduino.turnOnLight(callerNum)
    else if caller[caller.length - 1] in ["R", "F"]
      @arduino.turnOnLight(caller[5..])

    Q()

  turnOffLight: (caller, blink = false) ->
    if !blink and @blinkTimers[caller]?
      clearTimeout @blinkTimers[caller] 
   
    if caller in @people
      callerNum = (_.indexOf @people, caller) + 1
      @arduino.turnOffLight(callerNum)
    else if caller[caller.length - 1] in ["R", "F"]
      @arduino.turnOffLight(caller[5..])

    Q()


  blinkLight: ({caller, rate}) ->
    if rate is 0
      @turnOnLight(caller)
      return

    clearTimeout @blinkTimers[caller] if @blinkTimers[caller]?

    if @blinkState[caller]
      @turnOnLight(caller, true)
      @blinkState[caller] = false
    else
      @turnOffLight(caller, true)
      @blinkState[caller] = true

    callerNum = (_.indexOf @people, caller) + 1
    @blinkTimers[caller] = setTimeoutR rate, ( => @blinkLight({caller, rate}) )

    Q()

  sayToConnect: ({sender, receiver}) ->
    filepath = "#{__dirname}/../../audio/#{sender}/#{receiver}.aiff"
    deferred = Q.defer()
    sfx.play filepath, deferred.makeNodeResolver()
    return deferred.promise

  sayText: (identifier, text) ->
    # TODO: Load actual audio files
    deferred = Q.defer()
    sfx.say "\"#{text}\"", deferred.makeNodeResolver()
    return deferred.promise

  onReady: (cb) ->
    @arduino.on "ready", ->
      setTimeout(cb, 2000)

module.exports = ArduinoInterface