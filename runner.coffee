Game = require './game'
ConsoleInterface = require './interfaces/console_interface'

game = new Game()
game.addInterface (new ConsoleInterface())
game.startGame()