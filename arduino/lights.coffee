serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Lights
  constructor: (@device) ->
    @queue = []
    @sending = false

    # @turnOn(i) for i in [32..51]

    @device.on "data", (data) =>
      console.log "RECEIVE: ", data if @debug

  turnOn: (num) ->
    @enqueue "#{num} 1 \n"

  turnOff: (num) ->
    @enqueue "#{num} 0 \n"

  enqueue: (buf) ->
    @queue.push buf
    @tryToSend()

  tryToSend: =>
    return if @sending
    buf = @queue.shift()
    return unless buf?
    @sending = true    

    return unless buf?

    @device.write buf, =>
      console.log "Wrote #{buf}" if @debug
      @device.drain () =>
        @sending = false
        @tryToSend()


module.exports = Lights