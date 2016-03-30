root = exports ? this
root._ = require('underscore') unless root._?

root.CablePair = require('./cablePair')
root.Call = require('./call')

root.GameMode = require('./modes/gameMode')

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
  
  ###
  # Public API
  ###

  constructor: ->
    @cables = {}
    for i in [0...10]
      @cables[i] = new root.CablePair(i)

    @interfaces = []

  addInterface: (i) ->
    i.onReady =>
      i.people = @people
      i.client = @

      i.setPeople?(@people)

      @interfaces.push i

  startGame: ->
    @running = true
    @mode = new root.GameMode(@)
    @mode.start()

  stopGame: ->
    @running = false
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
    root._(@interfaces).chain()
      .without(callingInterface)
      .each ( (i) -> i.didConnect?(cableString, caller) )

    [cableNumber, isFront] = @parseCableString(cableString)
    cable = @cables[cableNumber]
    return unless cable?

    @mode.connect(cable, isFront, caller)

  disconnect: (first, second, callingInterface) =>
    root._(@interfaces).chain()
      .without(callingInterface)
      .each ( (i) -> i.didDisconnect?(first, second) )

    @mode.disconnect?(first, second)

  toggleSwitch: (cableString, state, callingInterface) =>
    #TODO: This will get abstracted out later
    if !@running
      if root._.chain(@cables)
        .pluck("frontSwitch")
        .reduce( ((memo, val) -> memo and (val is root.CablePair.SwitchState.Neutral)), true)
        .value()
          console.log "RESETTING"
          @startGame()

    root._(@interfaces).chain()
      .without(callingInterface)
      .each ( (i) -> i.didToggleSwitch?(cableString, state) )

    [cableNumber, isFront] = @parseCableString(cableString)
    cable = @cables[cableNumber]
    return unless cable?

    unless @mode.toggleSwitch(cable, isFront, state)
      # Here be magical special cases
      # Re-play Talk if appropriate
      if call?.state is root.State.WaitingToConnect and cable.rearSwitch is root.Switch.Talk and !isFront
        for i in @interfaces
          i.sayToConnect(call)

      # RESET THE GAME by flipping all front switches to talk
      if root._.chain(@cables)
        .pluck("frontSwitch")
        .reduce( ((memo, val) -> memo and (val is root.CablePair.SwitchState.Talk)), true)
        .value()
          @stopGame()
     
  ###
  # Mode methods
  ###

  turnOnLight: (light) -> i.turnOnLight(light) for i in @interfaces
  turnOffLight: (light) -> i.turnOffLight(light) for i in @interfaces
  blinkLight: (opts = {}) -> i.blinkLight(opts) for i in @interfaces
  sayToConnect: (call) -> i.sayToConnect(call) for i in @interfaces
  sayText: (identifier, text) -> i.sayText(identifier, text) for i in @interfaces


  ###
  # Private
  ###
  parseCableString: (cableString) -> [cableString[5], cableString[6] is "F"]


if module?.exports
  module.exports = Game
else if exports?
  exports = Game

