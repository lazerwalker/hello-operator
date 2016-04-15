root = exports ? this
root._ = require('underscore') unless root._?
root.Q = require('q')

root.CablePair = require('./cablePair')
root.Call = require('./call')

root.AttractMode = require('./modes/attractMode')
root.GameMode = require('./modes/gameMode')
root.ResetMode = require('./modes/resetMode')
root.SilentMode = require('./modes/silentMode')
root.TutorialMode = require('./modes/tutorialMode')
root.Resetter = require('./resetter')

root.Switch = root.CablePair.SwitchState
root.State = root.Call.State

setTimeoutR = (time, fn) -> setTimeout(fn, time)

###
Informal API

@protocol Client

function turnOnLight(caller)
function turnOffLight(caller)
function blinkLight({caller, rate}) // This is how it is because I don't know how to make JSCore accept multi-argument fns
function sayToConnect(call)
function sayText(text, identifier)

@end

@protocol Game

var client
var people

function connect(cable, caller)
function disconnect(cable, caller)
function toggleSwitch(cable, state) // state is -1, 0, or 1. Default is 0

@end

###

class Game
  people: [
    "Ethel"
    "Rosemary"
    "Donald"
    "Margie"
    "Rita"
    "Julius"
    "Herbert"
    "Joyce"
    "Edwin"
    "Franklin"

    "Dolores"
    "Walter"
    "Mabel"
    "Clarence"
    "Gladys"
    "Lee"
    "Melvin"
    "Bernice"
    "Everett"
    "Mae"
  ]

  modes: [
    root.AttractMode,
    root.SilentMode,
    root.GameMode,
    root.ResetMode
  ]

 
  ###
  # Public API
  ###

  constructor: ->
    @cables = {}
    for i in [0...10]
      @cables[i] = new root.CablePair(i)

    @interfaces = []
    @connected = []

    @resetter = new root.Resetter 20, => 
      @currentModeIndex = -1
      @nextMode()

    @currentModeIndex = 0

  addInterface: (i) ->
    i.onReady =>
      i.people = @people
      i.client = @

      i.setPeople?(@people)

      @interfaces.push i

  startGame: ->
    Mode = @modes[@currentModeIndex]

    @mode = new Mode(@)
    @mode.start()
    if @mode.allowAutoReset
      @resetter.enable()
    else
      @resetter.disable()

  reset: ->
    @nextMode()
    @currentModeIndex = 0

  nextMode: ->
    @stopGame()
    delete @mode
    @currentModeIndex++
    if @currentModeIndex >= @modes.length
      @currentModeIndex = 0
    @startGame()

  stopGame: ->
    @mode.stop()

    for i in @interfaces
      for p in @people
        i.turnOffLight(p)
      for id, c of @cables
        i.turnOffLight(c.rearLight)
        i.turnOffLight(c.frontLight)

  ###
  # Interface methods
  ###  
  connect: (cableString, caller, callingInterface) =>
    @resetter.keepAlive()

    root._(@interfaces).chain()
      .without(callingInterface)
      .each ( (i) -> i.didConnect?(cableString, caller) )

    [cableNumber, isFront] = @parseCableString(cableString)
    cable = @cables[cableNumber]
    return unless cable?

    @connected[caller] = true
    @connected[cableString] = true

    @mode.connect(cable, isFront, caller)

  disconnect: (first, second, callingInterface) =>
    @resetter.keepAlive()

    root._(@interfaces).chain()
      .without(callingInterface)
      .each ( (i) -> i.didDisconnect?(first, second) )

    @mode.disconnect?(first, second)

    @connected[first] = false
    @connected[second] = false

  toggleSwitch: (cableString, state, callingInterface) =>
    @resetter.keepAlive()

    root._(@interfaces).chain()
      .without(callingInterface)
      .each ( (i) -> i.didToggleSwitch?(cableString, state) )

    [cableNumber, isFront] = @parseCableString(cableString)
    cable = @cables[cableNumber]
    return unless cable?

    @mode.toggleSwitch(cable, isFront, state)
     
  ###
  # Mode methods
  ###

  promiseMapAcrossInterfaces: (methodName, args, interfaces) ->
    unless root._.isArray(args)
      args = [args]

    interfaces ?= @interfaces
    promises = root._.map(interfaces, (i) -> i[methodName](args...))
    root.Q.all promises

  turnOnLight: (light) -> @promiseMapAcrossInterfaces("turnOnLight", light)
  turnOffLight: (light) -> @promiseMapAcrossInterfaces("turnOffLight", light)
  blinkLight: (opts = {}) -> @promiseMapAcrossInterfaces("blinkLight", opts)
  sayToConnect: (call) -> @promiseMapAcrossInterfaces("sayToConnect", call)
  sayText: (identifier, text) -> @promiseMapAcrossInterfaces("sayText", [identifier, text])


  ###
  # Private
  ###
  parseCableString: (cableString) -> [cableString[5], cableString[6] is "F"]


if module?.exports
  module.exports = Game
else if exports?
  exports = Game

