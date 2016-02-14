import JavaScriptCore

class GameManager {
    let context = JSContext()

    init() {
        let log: @convention(block) (String) -> Void = { string1 in
            print("log:\(string1)")
        }
        let setTimeout: @convention(block) (JSValue, JSValue) -> Void = { function, timeout in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeout.toDouble() * Double(NSEC_PER_MSEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                function.callWithArguments([])
            }
        }

        context.objectForKeyedSubscript("console").setObject(unsafeBitCast(log, AnyObject.self), forKeyedSubscript: "log");
        context.setObject(unsafeBitCast(setTimeout, AnyObject.self), forKeyedSubscript: "setTimeout")

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
    }

    func startGame(interface:JSInterface) {
        context.setObject(interface, forKeyedSubscript: "JSInterface")
        context.evaluateScript("var game = new Game()")
        context.evaluateScript("game.addInterface(JSInterface)")
        context.evaluateScript("game.startGame()")
    }
}
