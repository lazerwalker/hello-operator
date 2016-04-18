Game = require './src/game'
# RpiInterface = require './interfaces/rpi_interface'
ConsoleInterface = require('./src/interfaces/console_interface')
ArduinoInterface = require('./src/interfaces/arduino_interface')
WebSocketInterface = require('./src/interfaces/websocket_interface')

# arduino = new ArduinoInterface([
#   "/dev/cu.usbmodemFD1211"
#   "/dev/cu.usbmodemFD1221"
#   "/dev/cu.usbmodemFD1231"
#   "/dev/cu.usbmodemFD1241"  
#  ])

arduino = new ArduinoInterface([], true)

console = new ConsoleInterface()
# ws = new WebSocketInterface("ws://Playful.local:3000")

game = new Game()

game.addInterface console
# game.addInterface arduino
# game.addInterface ws

game.startWhenReady()