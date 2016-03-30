chai = require('chai')
sinon = require('sinon')
sinonChai = require('sinon-chai')
expect = chai.expect

chai.use(sinonChai)

TutorialMode = require('../src/modes/tutorialMode')
shouldBeAMode = require('./modes')

describe "TutorialMode", ->
  beforeEach ->
    @game = sinon.spy()
    @mode = new TutorialMode(@game)
    
  shouldBeAMode()
