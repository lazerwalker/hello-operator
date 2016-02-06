import Foundation
import JavaScriptCore

enum SwitchIndex: Int {
    case Talk = -1, Neutral, Ring
}

@objc protocol JSInterfaceExports : JSExport {
    var people: [String] { get set }
    var client: JSValue? { get set }

    func turnOnLight(sender: String)
    func turnOffLight(sender: String)
    func blinkLight(obj:[String: AnyObject])
    func sayToConnect(call:[String: AnyObject])
}

@objc class JSInterface : NSObject, JSInterfaceExports {
    var onTurnOn:((String) -> Void)?
    var onTurnOff:((String) -> Void)?
    var onBlink:((String, NSTimeInterval) -> Void)?
    var onPeopleChange:(([String]) -> Void)?
    var onSayToConnect:((sender: String, receiver:String) -> Void)?

    var currentGoal:(String, String?)?

    let OPERATOR = "OPER"

    dynamic var people:[String] = [] {
        didSet {
            self.onPeopleChange?(self.people)
        }
    }
    
    dynamic var client: JSValue?

    //-
    // Called from JS

    func turnOnLight(sender: String) {
        print("Turning on \(sender)")
        self.onTurnOn?(sender)
    }

    func turnOffLight(sender: String) {
        print("Turning off \(sender)")
        self.onTurnOff?(sender)
    }

    func blinkLight(obj:[String: AnyObject]) {
        let caller = obj["caller"] as! String
        let rate = obj["rate"] as! Double
        print("Blinking \(caller), \(rate)")
        let interval:NSTimeInterval = rate / 1000
        self.onBlink?(caller, interval)
    }

    func sayToConnect(call:[String:AnyObject]) {
        let sender = call["sender"] as! String
        let receiver = call["receiver"] as! String

        self.onSayToConnect?(sender: sender, receiver: receiver)
    }

    //-
    // Called from view controller
    func connect(first:String, _ second:String) {
        self.client?.objectForKeyedSubscript("connect").callWithArguments([first, second])
    }

    func disconnect(first:String, _ second:String) {
        self.client?.objectForKeyedSubscript("disconnect").callWithArguments([first, second])
    }

    func toggleSwitch(cable:String, state:SwitchIndex) {
        self.client?.objectForKeyedSubscript("toggleSwitch").callWithArguments([cable, state.rawValue])
    }
}