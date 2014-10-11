_ = require "underscore"

PhonePin = 9

pinMapping = {
  10: "Alice",
  11: "Bob",
  12: "Charlie",
  13: "Daniel"
}

# Game
calls = []

pickUpPhone = (caller) ->
  call = _(calls).findWhere {sender: caller}
  return unless call

  console.log "Picked up #{call.sender}"
  calls = _(calls).without(call)
  addNewCall()

addNewCall = ->
  [first, second] = _.sample(Object.keys(pinMapping), 2)

  instruction = {
    sender: pinMapping[first],
    receiver: pinMapping[second]
  }

  calls.push(instruction)
  console.log "#{instruction.sender} is calling!"

addNewCall()

# Serial port
serialport = require "serialport"
SerialPort = serialport.SerialPort
serial = new SerialPort "/dev/tty.usbserial-A5025WB7",
  parser: serialport.parsers.readline '\r'

serial.on "open", =>
  serial.on "data", (data) =>
    console.log data
    event = JSON.parse(data)

    if PhonePin in event.values
      other = _.without(event.values, PhonePin)[0]
      otherName = pinMapping[other]
      pickUpPhone(otherName)
