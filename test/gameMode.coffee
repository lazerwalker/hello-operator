chai = require('chai')
sinon = require('sinon')
sinonChai = require('sinon-chai')
expect = chai.expect

chai.use(sinonChai)

GameMode = require('../src/modes/gameMode')
shouldBeAMode = require('./modes')

describe "GameMode", ->
  beforeEach ->
    @game = sinon.spy()
    @mode = new GameMode(@game)

  shouldBeAMode()
