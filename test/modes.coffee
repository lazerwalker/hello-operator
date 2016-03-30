chai = require('chai')
sinon = require('sinon')
sinonChai = require('sinon-chai')
expect = chai.expect

module.exports = ->
  describe 'control flow', ->
    it 'should be able to start', ->
      expect(@mode.start).to.exist

    it 'should be able to stop', ->
      expect(@mode.stop).to.exist

  describe 'updating state', ->
    it 'should be able to connect', ->
      expect(@mode.connect).to.exist

    it 'should be able to disconnect', ->
      expect(@mode.disconnect).to.exist

    it 'should be able to toggle switches', ->
      expect(@mode.toggleSwitch).to.exist

  it 'should have access to its game object', ->
    expect(@mode.game).to.equal(@game)

