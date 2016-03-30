chai = require('chai')
sinon = require('sinon')
sinonChai = require('sinon-chai')
expect = chai.expect

chai.use(sinonChai)

Game = require('../src/game')

describe "initialization", ->
  # This is a pretty bad test, that basically exists to prove to myself that the test setup works
  it "should have valid cables", ->
    g = new Game()
    expect(Object.keys(g.cables)).to.have.lengthOf(10)
