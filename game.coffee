_ = require "underscore"

PhonePin = 2

people = [
  {pin: 3, name: "1A"},
  {pin: 4, name: "1B"},
  {pin: 5, name: "1C"},
  {pin: 6, name: "1D"},
  {pin: 7, name: "1E"},
  {pin: 8, name: "2A"},
  {pin: 9, name: "2B"},
  {pin: 10, name: "2C"},
  {pin: 11, name: "2D"},
  {pin: 12, name: "2E"},
]

# Game
calls = []

pickUpPhone = (caller) ->
  call = _(calls).findWhere {sender: caller}
  return unless call
  return if call.pickedUp

  call.pickedUp = true

  console.log "Picked up #{call.sender.name}"
  console.log "\"Hey, it's #{call.sender.name}. Can I talk to #{call.recipient.name}?\""

match = (callers) ->
  first = callers[0]
  second = callers[1]

  call = _(calls).findWhere {sender: first, recipient: second}
  unless call
    call = _(calls).findWhere {sender: second, recipient: first}
  return unless call

  console.log "Yay!"

  first.busy = false
  second.busy = false

  calls = _(calls).without(call)
  addNewCall()

addNewCall = ->
  [first, second] = _(people).chain()
    .reject((p) -> p.busy)
    .sample(2)
    .value()

  return unless first and second

  instruction = {
    sender: first,
    recipient: second
  }

  first.busy = true
  second.busy = true

  calls.push(instruction)
  console.log "#{instruction.sender.name} is calling!"

# Serial port
serialport = require "serialport"
SerialPort = serialport.SerialPort
serial = new SerialPort "/dev/tty.usbserial-A5025WB7",
  parser: serialport.parsers.readline "\r\n"

serial.on "open", =>
  serial.on "data", (data) =>
    event = JSON.parse(data)
    if event.type is "on"
      if PhonePin in event.values
        otherPin = _.without(event.values, PhonePin)[0]
        other = _(people).findWhere pin: otherPin
        pickUpPhone(other)
      else
        event.values = event.values.map (pin) -> _(people).findWhere pin: pin
        match(event.values)

# Start it up!
addNewCall()