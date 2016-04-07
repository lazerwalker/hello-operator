Q = require('q')

class TutorialMode
  constructor: (@game) ->
    @running = false

  start: ->
    @running = true

    text1 = "Hey there, so glad you could fill in. You can see things are going to get busy pretty quickly. Look, you can see that Mabel's calling"
    text2 = "You should plug in one of the cables below"

    Q().then =>
      @game.sayText("tutorial1", text1)
    .then =>
      @game.turnOnLight("Mabel")
    .then =>
      @game.sayText("tutorial2", text2)

  stop: ->

  connect: (cable, isFront, caller) ->

  disconnect: (cable, isFront, caller) ->

  toggleSwitch: (cable, isFront, state) ->


module.exports = TutorialMode