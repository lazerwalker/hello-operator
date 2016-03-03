Game = require './src/game'
# RpiInterface = require './interfaces/rpi_interface'
ConsoleInterface = require('./src/interfaces/console_interface')
ArduinoInterface = require('./src/interfaces/arduino_interface')

arduino = new ArduinoInterface([], true)
#   "/dev/cu.usbmodem14211"
#   "/dev/cu.usbmodem14221"
#   "/dev/cu.usbmodem14231"
#   "/dev/cu.usbmodem14241"  
# ])

console = new ConsoleInterface()

game = new Game()

game.addInterface console
game.addInterface arduino
game.startGame()

# arduino.onReady ->
#   game.addInterface arduino
#   game.startGame()