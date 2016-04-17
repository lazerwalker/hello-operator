chai = require('chai')
sinon = require('sinon')
sinonChai = require('sinon-chai')
expect = chai.expect

Resetter = require('../src/resetter')

setTimeoutR = (t, fn) -> setTimeout(fn, t)

describe "Resetter", ->
  beforeEach ->
    @callback = sinon.spy()
    @resetter = new Resetter(0, @callback)

  context "when the resetter is first created", ->
    it "should not reset by default", ->
      expect(@callback).to.not.have.beenCalled

  context "when the resetter is enabled and has passed enough time", ->
    it "should reset", ->
      @resetter.enable()
      expect(@callback).to.have.beenCalled

  describe "Specifying a timeout in seconds", ->
    context "when enabled", ->
      it "should wait the specified number of seconds", (done) ->
        @resetter = new Resetter 0.25, ->
          end = new Date()
          expect(end - start).to.be.closeTo(250, 10)
          done()
        start = new Date()      
        @resetter.enable()

      it "should wait a different number of seconds", (done) ->
        @resetter = new Resetter 0.5, ->
          end = new Date()
          expect(end - start).to.be.closeTo(500, 20)
          done()
        start = new Date()
        @resetter.enable()  

  describe "when enabled a while after being created", ->
    it "should start counting from enable, not create", (done) ->
      start = new Date()

      setTimeoutR 250, ->
        @resetter = new Resetter 0.25, ->
          end = new Date()
          expect(end - start).to.be.closeTo(500, 20)
          done()
        @resetter.enable()

  # TODO: I don't know why these tests can't use sinon
  describe "disabling after being enabled", ->
    it "should not reset", (done) ->
      called = false
      resetter = new Resetter 0.01, (-> called = true)
      resetter.enable()
      resetter.disable()

      setTimeoutR 20, ->
        expect(called).to.be.false
        done()

  describe "being kept awake", ->
    it "should not reset", (done) ->
      called = false
      resetter = new Resetter(0.1, (-> called = true))
      resetter.enable()

      resetter.keepAlive()
      for i in [0.01..0.1] by 0.01
        setTimeoutR(i, -> resetter.keepAlive())

      setTimeoutR 100, ->
        expect(called).to.be.false
        done()

