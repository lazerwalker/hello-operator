import Foundation
import JavaScriptCore

@objc protocol JSInterfaceExports : JSExport {
    var people: [String] { get set }
    var client: JSValue? { get set }

    func initiateCall(sender:String)
    func askToConnect(call:[String: AnyObject])
    func askToDisconnect(call:[String: AnyObject])
    func completeCall(call:[String: AnyObject])
}

@objc class JSInterface : NSObject, JSInterfaceExports {
    var onInitiateCall:((sender: String) -> Void)?
    var onAskToDisconnect:((sender: String, receiver:String) -> Void)?
    var onAskToConnect:((sender: String, receiver:String) -> Void)?
    var onCompleteCall:((sender: String, receiver:String) -> Void)?
    var onPeopleChange:(([String]) -> Void)?

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

    func initiateCall(sender: String) {
        print("\(sender) is calling!")
        self.onInitiateCall?(sender: sender)
    }

    func askToDisconnect(call:[String: AnyObject]) {
        print("Asking to disconnect")
        let sender = call["sender"] as! String
        let receiver = call["receiver"] as! String

        self.onAskToDisconnect?(sender: sender, receiver: receiver)
    }

    func askToConnect(call:[String:AnyObject]) {
        let sender = call["sender"] as! String
        let receiver = call["receiver"] as! String

        self.onAskToConnect?(sender: sender, receiver: receiver)
    }

    func completeCall(call: [String : AnyObject]) {
        let sender = call["sender"] as! String
        let receiver = call["receiver"] as! String

        self.onCompleteCall?(sender: sender, receiver: receiver)
    }

    //-
    // Called from view controller
    func connect(first:String, _ second:String) {
        if first == OPERATOR {
            self.client?.objectForKeyedSubscript("connectOperator").callWithArguments([second])
        } else if second == OPERATOR {
            self.client?.objectForKeyedSubscript("connectOperator").callWithArguments([first])
        } else {
            self.client?.objectForKeyedSubscript("connect").callWithArguments([first, second])
        }
    }

    func disconnect(first:String, _ second:String) {
        if first == OPERATOR {
            self.client?.objectForKeyedSubscript("disconnectOperator").callWithArguments([second])
        } else if second == OPERATOR {
            self.client?.objectForKeyedSubscript("disconnectOperator").callWithArguments([first])
        } else {
            self.client?.objectForKeyedSubscript("disconnect").callWithArguments([first, second])
        }
    }
}