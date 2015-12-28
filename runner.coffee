Game = require './game'
# RpiInterface = require './interfaces/rpi_interface'
ConsoleInterface = require('./interfaces/console_interface')

game = new Game()
game.addInterface (new ConsoleInterface())
game.startGame()