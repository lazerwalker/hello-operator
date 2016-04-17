Q = require('q')

class TutorialMode
  constructor: (@game) ->
    @running = false

  start: ->
    @running = true

    text1 = "Hey there, so glad you could fill in. You can see things are going to get busy pretty quickly. Look, you can see that Mabel's calling"
    text2 = "You should plug in one of the cables below"

    Q().then =>
      @game.sayText("tutorial1", "Hey there, so glad you could fill in")
    .then =>      
      @game.turnOnLight("Mabel")
    .then =>
      @game.sayText("tutorial2", "Look, Mabel wants to make a call. Plug a rear cable into her")
      # Condition: connect rear cable to Mabel
      # Fail state: switch
      # Fail state: front cable
      # Fail state: cable to wrong person
    .then =>
      @game.sayText("tutorial3", "Take the phone, then flip the rear switch away from you")
      # Condition: flip matching rear switch to talk
      # Fail state: front switch
      # Fail state: wrong switch
      # Fail state: ring rather than switch
    .then =>
      @game.sayText("tutorial4", "Awesome, now un-flip the switch"
      # Condition: flip switch back to neutral 
    .then =>
      @game.sayText("tutorial4", "Now connect the front cable to Dolores. if you missed it, re-flip")
      # Condition: connect matching front cable to Dolores
      # Fail state: wrong person
      # Fail state: wrong cable
      # Fail state: switch
    .then =>
      @game.sayText("tutorial5", "Now flip front to ring"
      # Condition: flip front to ring (talk?)
      # Fail: wrong position?
      # Fail: rear switch
      # Fail: other switch
    .then =>
      @game.sayText("tutorial6", "Cool. While it's blinking, the phone is ringing. When it turns solid, they're talking to each other. Undo the switches.")
    .then =>
      # "Cool, the lights just turned out. That means they're done talking to each other. Disconnect the cables"
      # Condition: disconnect
    .then =>
      # "You've got it! Do try to keep up."

  stop: ->

  connect: (cable, isFront, caller) ->

  disconnect: (cable, isFront, caller) ->

  toggleSwitch: (cable, isFront, state) ->


module.exports = TutorialMode