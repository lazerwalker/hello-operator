chai = require('chai')
sinon = require('sinon')
sinonChai = require('sinon-chai')
expect = chai.expect

chai.use(sinonChai)

Game = require('../src/game')
TutorialMode = require('../src/modes/tutorialMode')
shouldBeAMode = require('./modes')

describe "TutorialMode", ->
  beforeEach ->
    @game = new Game()

    @mode = new TutorialMode(@game)
    
  shouldBeAMode()

  describe "tutorial flow", ->
    it.only "should say hello", ->
      @game.sayText = sinon.spy()
      @mode.start()
      expect(@game.sayText).to.have.been.calledWith("tutorial1")

