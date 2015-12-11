Game = require './game'
RpiInterface = require './interfaces/rpi_interface'

game = new Game()
game.addInterface (new RpiInterface())
game.startGame()