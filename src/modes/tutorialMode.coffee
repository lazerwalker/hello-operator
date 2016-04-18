Q = require('q')
Storyboard = require('storyboard-engine')
storyboardFile = require('fs').readFileSync('./tutorial.json', 'utf8')

SwitchState = require('../cablePair').SwitchState

class TutorialMode
  constructor: (@game) ->
    @storyboard = new Storyboard(JSON.parse(storyboardFile))

    @storyboard.addOutput 'text', (text, passageId) =>
      @game.sayText(passageId, text).then =>
        @storyboard.completePassage(passageId)

    @storyboard.addOutput 'turnOnLight', (light, passageId) =>
      @game.turnOnLight(light).then =>
        @storyboard.completePassage(passageId)

    @storyboard.addOutput 'sayToConnect', (data, passageId) =>
      people = data.split ","
      call = {sender: people[0], receiver: people[1]}
      @game.sayToConnect(call).then =>
        @storyboard.completePassage(passageId)

    @storyboard.addOutput 'blinkLight', (data, passageId) =>
      [caller, rate] = data.split ','
      rate = parseInt(rate)
      @game.blinkLight({caller, rate}).then =>
        @storyboard.completePassage(passageId)

    @storyboard.addOutput 'complete', (data, passageId) =>
      console.log "Complete"
      @game.nextMode()

    for p in @game.people
      @storyboard.receiveInput(p, {})

    @running = false

  start: ->
    @running = true
    @storyboard.start()
    ###
    Node 0
      * Fail state: switch
      * Fail state: front cable
      * Fail state: cable to wrong person

    Node 1
      * Fail state: front switch
      * Fail state: wrong switch
      * Fail state: ring rather than switch
    
    Node 2
      * Fail state: flip down to ring?
      * Fail state: wrong person
      * Fail state: wrong cable
      * Fail state: other switch failure

    Node 3
      * Fail: wrong position?
      * Fail: rear switch
      * Fail: other switch

    Node 4
      * TODO: Blink light
      * TODO: Delay blinking for a few seconds (can hack this in this file until storyboard supports it?)
      * TODO: Delay for a few seconds before light turns off
      * Fail: disconnect early
    ###

  stop: ->

  connect: (cable, isFront, caller) ->
    @storyboard.receiveInput("#{caller}.cable", cable.number)
    @storyboard.receiveInput("#{caller}.isFront", isFront)

    @cableCallers ?= {}
    @cableCallers[cable.toCableString(isFront)] = caller

  disconnect: (cable, isFront, caller) ->
    @storyboard.receiveInput("#{caller}.cable", undefined)      
    @storyboard.receiveInput("#{caller}.isFront", undefined)
    delete @cableCallers[cable.toCableString(isFront)]

  toggleSwitch: (cable, isFront, state) ->
    cableString = cable.toCableString(isFront)
    caller = @cableCallers[cableString]
    @storyboard.receiveInput("#{caller}.switch", state)      

module.exports = TutorialMode