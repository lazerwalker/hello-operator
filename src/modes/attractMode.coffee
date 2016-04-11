Q = require('q')
_ = require('underscore')

class AttractMode
  constructor: (@game) ->
    @running = false

  start: ->
    @running = true

    blinkLight = (port, interval) =>
      return () =>
        Q().then =>
          @game.turnOnLight(port)
        .then =>
          Q.delay(interval)
        .then =>
          @game.turnOffLight(port)

    blinkLights = (lights, interval, repeats=true) =>
      _(lights).chain()
        .map( (port) -> blinkLight(port, interval) )
        .reduce(Q.when)
        .value()
        .then( () => blinkLights(lights, interval) if repeats )

    # This garbage = reverse the second half of the list of names so it's a circle
    topRow = @game.people[0..10]
    bottomRow = @game.people[10..20].reverse()
    people = topRow.concat(bottomRow)

    blinkLights(people, 500, true)

  stop: ->

  connect: (cable, isFront, caller) ->

  disconnect: (cable, isFront, caller) ->

  toggleSwitch: (cable, isFront, state) ->


module.exports = AttractMode