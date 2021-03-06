Q = require('q')
_ = require('underscore')

SwitchState = require('../cablePair').SwitchState

class AttractMode
  allowAutoReset: false

  constructor: (@game) ->
    @running = false

  start: ->
    @running = true
    @blink()

  toggleSwitch: (cable, isFront, state) ->
    if state isnt SwitchState.Neutral
      @game.nextMode()
    return true

  stop: ->
    @running = false

  blink: ->
    blinkLight = (port, interval) =>
      return () =>
        Q().then =>
          throw new Error("Not running") unless @running
          @game.turnOnLight(port)
        .then =>
          throw new Error("Not running") unless @running
          Q.delay(interval)
        .then =>
          throw new Error("Not running") unless @running
          @game.turnOffLight(port)

    blinkLights = (lights, interval, repeats=true) =>
      _(lights).chain()
        .map( (port) -> blinkLight(port, interval) )
        .reduce(Q.when, Q())
        .value()
        .then () => 
          throw new Error("Not running") unless @running
          blinkLights(lights, interval) if repeats 
        .fail()

    topRow = @game.people[0...10]
    bottomRow = @game.people[10..20].reverse()
    people = topRow.concat(bottomRow)

    allPeople = [people]
    for n in [5, 10, 15]
      array = people[n..].concat(people[0...n])
      allPeople.push array

    red = [
      "cable1R"
      "cable3R"
      "cable5R"      
      "cable7R"
      "cable9R"
      "cable9F"
      "cable7F"
      "cable5F"
      "cable3F"
      "cable1F"
    ]
    white = [
      "cable0R"
      "cable8R"
      "cable6R"
      "cable4R"
      "cable2R"
      "cable2F"
      "cable4F"
      "cable6F"
      "cable8F"
      "cable0F"
    ]
    # Actuall call the things
    blinkLights(p, 150, true) for p in allPeople
    blinkLights(white, 150, true)
    blinkLights(red, 150, true)

    # This unused bunch of code lets you turn blocks of lights on and off as a unit
    cables = []
    cables.push "cable#{i}R" for i in [1...10]
    cables.push "cable0R"
    cables.push "cable0F"
    cables.push "cable#{i}F" for i in [9...0]

    white = []
    red = []
    for i in [0...10] by 2
      white.push "cable#{i}R"
      white.push "cable#{i}F"
      red.push "cable#{i+1}R"
      red.push "cable#{i+1}F"


    blinkMultipleLights = (lights, interval) =>
      return () =>
        Q().then =>
          actions = _.map(lights, (l) => @game.turnOnLight(l))
          Q.any(actions)
        .then =>
          Q.delay(interval)
        .then =>
          actions = _.map(lights, (l) => @game.turnOffLight(l))
          Q.any(actions)

    toggleLights = (groups, interval, repeats=true) =>
      _(groups).chain()
        .map( (lights) -> blinkMultipleLights(lights, interval) )
        .reduce(Q.when, Q())
        .value()
        .then( () => toggleLights(groups, interval) if repeats )
    #toggleLights([red, white], 300, true)

  connect: (cable, isFront, caller) ->

  disconnect: (cable, isFront, caller) ->

module.exports = AttractMode