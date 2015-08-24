PhonePin = 2

INPUT_RATE = 9600
INPUT_PORT= "/dev/tty.usbserial-A5025WB7"
OUTPUT_RATE = 9600
OUTPUT_PORT = "/dev/tty.usbmodem1411"

people = 
  1A: 3
  1B: 4
  1C: 5
  1D: 6
  1E: 7
  2A: 8
  2B: 9
  2C: 10
  2D: 11
  2E: 12

class PhysicalInterface
  initialize: ->
    # Serial port
    serialport = require "serialport"
    SerialPort = serialport.SerialPort

    input = new SerialPort INPUT_PORT,
      parser: serialport.parsers.readline "\r\n"
      baudrate: INPUT_RATE

    output = new SerialPort OUTPUT_PORT,
      parser: serialport.parsers.readline "\r\n"
      baudrate: OUTPUT_RATE

    input.on "open", =>
      input.on "data", (data) =>
        event = JSON.parse(data)
        if event.type is "on"
          if PhonePin in event.values
            otherPin = _.without(event.values, PhonePin)[0]
            other = _(people).findWhere pin: otherPin
            pickUpPhone(other)
          else
            event.values = event.values.map (pin) -> _(people).findWhere pin: pin
            match(event.values)

    output.on "open", ->
      output.on "data", (data) ->
        if data is "ready"
          addNewCall()

  illuminate: (person) ->
    output.write "#{people[person]}"

  deIlluminate: (person) ->
    output.write "-#{people[person]}"

module.exports = PhysicalInterface
