serialport = require "serialport"
SerialPort = serialport.SerialPort

setTimeoutR = (t, fn) -> setTimeout(fn, t)

class Cables
  name: 'cables'

  constructor: (port, rate=9600) ->
    @connected = false
    @device = new SerialPort port,
      parser: serialport.parsers.readline "\r\n"
      baudrate: rate

    @cables = {}

    @device.on "error", (e) -> console.log e
    @device.on "open", =>
      @device.on "data", (data) =>
        if @connected 
          @parseData(data)
        else 
          if data is "\"#{@name}\""
            @connected = true
            console.log "Connected to device '#{@name}', waiting for input"
          else
            console.log "Received unexpected data: '#{data}'"

  parseData: (json) ->
    {connected, cable, port} = JSON.parse(json)
    oldPort = @cables[cable]

    if connected is true and oldPort is port
      return
    else if connected is false and oldPort isnt port
      return
    else if connected is true and not oldport?
      @cables[cable] = port
      console.log "Connected #{cable} to #{port}"
    else if connected is false and oldPort is port
      delete @cables[cable]
      console.log "Disconnected #{cable} and #{port}"

module.exports = Cables