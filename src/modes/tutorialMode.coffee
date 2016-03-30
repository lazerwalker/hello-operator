class TutorialMode
  constructor: (@game) ->
    @running = false

  start: ->
    @running = true
    @game.sayText("tutorial1", "Hey there! So glad you could fill in. You can see things are going to get busy pretty quickly. Look, you can see that Mabel's calling")
    @game.turnOnLight("Mabel")
    @game.sayText("tutorial2", "You should plug in one of the cables below")

  stop: ->

  connect: (cable, isFront, caller) ->

  disconnect: (cable, isFront, caller) ->

  toggleSwitch: (cable, isFront, state) ->


module.exports = TutorialMode