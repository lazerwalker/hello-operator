ArduinoGroup = require('./arduino_group')

a = new ArduinoGroup([
  # "/dev/cu.usbmodem14121"

  "/dev/cu.usbmodem14211"
  "/dev/cu.usbmodem14221"
  "/dev/cu.usbmodem14231"
  "/dev/cu.usbmodem14241"  
])

a.on "ready", =>
  a.debug = true