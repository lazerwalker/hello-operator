import JavaScriptCore

class GameManager {
    let context:JSContext

    init() {
        context = JSContext()

        let log: @convention(block) (String) -> Void = { string1 in
            print("log:\(string1)")
        }
        context.objectForKeyedSubscript("console").setObject(unsafeBitCast(log, AnyObject.self), forKeyedSubscript: "log");

        let underscorePath = NSBundle.mainBundle().pathForResource("underscore", ofType: "js")
        var us = ""
        do {
            us = try String(contentsOfFile: underscorePath!)
        }
        catch let error as NSError {
            error.description
        }
        context.evaluateScript(us)

        let path = NSBundle.mainBundle().pathForResource("game", ofType: "js")
        var gameString = ""
        do {
            gameString = try String(contentsOfFile: path!)
        }
        catch let error as NSError {
            error.description 
        }

        context.evaluateScript(gameString)

        let interface = JSInterface()
        context.setObject(interface, forKeyedSubscript: "JSInterface")

        context.evaluateScript("var game = new Game()")
        context.evaluateScript("game.addInterface(JSInterface)")
        context.evaluateScript("game.startGame()")
    }
}
