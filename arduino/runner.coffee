Switches = require('./switches')
Cables = require('./cables')
Lights = require('./lights')

c = new Cables("/dev/cu.usbmodem14211")
s = new Switches("/dev/cu.usbmodem14221")
lights = new Lights("/dev/cu.usbmodem14231")
lights2 = new Lights("/dev/cu.usbmodem14241")