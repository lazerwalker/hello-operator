Game = require './src/game'
# RpiInterface = require './interfaces/rpi_interface'
ConsoleInterface = require('./src/interfaces/console_interface')
ArduinoInterface = require('./src/interfaces/arduino_interface')
WebSocketInterface = require('./src/interfaces/websocket_interface')

arduino = new ArduinoInterface([
   "/dev/cu.usbmodemFD1311"
   "/dev/cu.usbmodemFD1321"
   "/dev/cu.usbmodemFD1331"
   "/dev/cu.usbmodemFD1341"  
  ])

console = new ConsoleInterface()
# ws = new WebSocketInterface("ws://Playful.local:3000")

game = new Game()

game.addInterface console
game.addInterface arduino
# game.addInterface ws

arduino.onReady ->
  game.startGame()
