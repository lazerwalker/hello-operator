setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Resetter
  constructor: (seconds, @resetFunction) ->
    @timeout = seconds * 1000

  enable: ->
    @enabled = true
    @startTimer()

  disable: ->
    @enabled = false
    clearTimeout(@timer)

  keepAlive: ->
    return unless @enabled
    clearTimeout(@timer)
    @startTimer()

  startTimer: ->

    @timer = setTimeoutR @timeout, =>
      @enabled = false
      @resetFunction?()

module.exports = Resetter