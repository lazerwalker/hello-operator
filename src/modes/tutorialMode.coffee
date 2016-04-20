Q = require('q')
Storyboard = require('storyboard-engine')
storyboardFile = require('fs').readFileSync('./tutorial.json', 'utf8')

setTimeoutR = (t, fn) -> setTimeout(fn, t)

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

    @storyboard.addOutput 'turnOffLight', (light, passageId) =>
      @game.turnOffLight(light).then =>
        @storyboard.completePassage(passageId)        

    @storyboard.addOutput 'blinkLight', (data, passageId) =>
      [caller, rate] = data.split ","
      @game.blinkLight({caller, rate}).then =>
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

    @storyboard.addOutput 'pause', (delay, passageId) =>
      setTimeoutR delay, => @storyboard.completePassage(passageId)

    for p in @game.people
      @storyboard.receiveInput(p, {})

    @running = false
    @cablesByCaller = {}
    @callersByCable = {}

  start: ->
    @running = true
    @storyboard.start()

  stop: ->

  connect: (cable, isFront, caller) ->
    @cablesByCaller[caller] = cable
    @callersByCable[cable.toCableString(isFront)] = caller

    # Handle failures

    if (caller isnt "Mabel" and caller isnt "Dolores") or 
      (caller is "Dolores" and !@cablesByCaller["Mabel"])
        @storyboard.receiveMomentaryInput("connectWrongPerson", caller)

    if caller is "Mabel" and isFront
        @storyboard.receiveMomentaryInput("connectWrongCable")

    else if caller is "Dolores"
      mabelCable = @cablesByCaller["Mabel"]
      if cable isnt mabelCable
        @storyboard.receiveMomentaryInput("connectWrongCable")

    @storyboard.receiveInput("#{caller}.cable", cable.number)
    @storyboard.receiveInput("#{caller}.isFront", isFront)

  disconnect: (cable, isFront, caller) ->
    @storyboard.receiveInput("#{caller}.cable", undefined)      
    @storyboard.receiveInput("#{caller}.isFront", undefined)
    delete @callersByCable[cable.toCableString(isFront)]
    delete @cablesByCaller[caller]

  toggleSwitch: (cable, isFront, state) ->
    cableString = cable.toCableString(isFront)
    caller = @callersByCable[cableString]

    if state isnt SwitchState.Neutral
      # Special cases for each individual tutorial state

      # Plug into Mabel
      if @storyboard.state.graph.currentNodeId is "0"
        @storyboard.receiveMomentaryInput("toggleWrongSwitch")

      # "Talk" to Mabel
      else if @storyboard.state.graph.currentNodeId is "1"
        if caller isnt "Mabel"
          mabelCable = @cablesByCaller["Mabel"]
          if cable is mabelCable and isFront
            @storyboard.receiveMomentaryInput("toggleWrongSwitchInPair")
          else
            @storyboard.receiveMomentaryInput("toggleWrongSwitch")
        else if state is SwitchState.Ring
          @storyboard.receiveMomentaryInput("toggleWrongSwitchDirection")

      # Unflip talk switch, plug into Dolores
      else if @storyboard.state.graph.currentNodeId is "2"
        @storyboard.receiveMomentaryInput("toggleWrongSwitch")

      # Flip front switch to ring
      else if @storyboard.state.graph.currentNodeId is "3"
        if caller is "Dolores" and state is SwitchState.Talk
          @storyboard.receiveMomentaryInput("toggleWrongSwitchDirection")
        else if caller is "Mabel"
          @storyboard.receiveMomentaryInput("toggleWrongSwitchInPair")
        else if caller isnt "Mabel" and caller isnt "Dolores"
          @storyboard.receiveMomentaryInput("toggleWrongSwitch")

      else if (caller isnt "Mabel" and caller isnt "Dolores")
        @storyboard.receiveMomentaryInput("toggleWrongSwitch")

    @storyboard.receiveInput("#{caller}.switch", state)      


module.exports = TutorialMode