Game = require './src/game'
# RpiInterface = require './interfaces/rpi_interface'
ConsoleInterface = require('./src/interfaces/console_interface')

game = new Game()
game.addInterface (new ConsoleInterface())
game.startGame()