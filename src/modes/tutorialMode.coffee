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
    # TODO: @storyboard.receiveInput(caller, cable)
    if caller is "Mabel" and !isFront
      @mabelCable = cable
      @storyboard.receiveInput("mabelIsConnected", true)

    if caller is "Dolores" and isFront
      @storyboard.receiveInput("doloresIsConnected", true)
      @doloresCable = cable

  disconnect: (cable, isFront, caller) ->
    if cable is @mabelCable and !isFront and caller is "Mabel"
      @storyboard.receiveInput("mabelIsConnected", false)
    if cable is @doloresCable and isFront and caller is "Dolores"
      @storyboard.receiveInput("doloresIsConnected", false)      

  toggleSwitch: (cable, isFront, state) ->
    if cable is @mabelCable or cable is @doloresCable
      if isFront 
        if state is SwitchState.Ring
          @storyboard.receiveInput('flipRingSwitch', true)
        else if state is SwitchState.Neutral
          @storyboard.receiveInput('flipRingSwitch', false)
      else
        if state is SwitchState.Talk
          @storyboard.receiveInput('flipTalkSwitch', true)
        else if state is SwitchState.Neutral
          @storyboard.receiveInput('flipTalkSwitch', false)
      

module.exports = TutorialMode