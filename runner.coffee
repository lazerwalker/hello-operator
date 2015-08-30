Game = require './game'
ConsoleInterface = require './interfaces/console_interface'

game = new Game()
game.addInterface ConsoleInterface
game.startGame()