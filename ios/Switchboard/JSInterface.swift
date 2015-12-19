import Foundation
import JavaScriptCore

@objc protocol JSInterfaceExports : JSExport {
    var people: [String] { get set }
    var client: JSValue? { get set }

    func initiateCall(sender:String)
    func askToConnect(call:[String: AnyObject])
    func askToDisconnect(call:[String: AnyObject])
}

@objc class JSInterface : NSObject, JSInterfaceExports {
    var onInitiateCall:((sender: String) -> Void)?
    var onAskToDisconnect:((sender: String, receiver:String) -> Void)?
    var onAskToConnect:((sender: String, receiver:String) -> Void)?
    var onPeopleChange:(([String]) -> Void)?

    var currentGoal:(String, String?)?
    var onGoalCompletion:(() -> Void)?

    dynamic var people:[String] = [] {
        didSet {
            self.onPeopleChange?(self.people)
        }
    }
    
    dynamic var client: JSValue?

    func initiateCall(sender: String) {
        print("\(sender) is calling!")

        currentGoal = (sender, "OPER")
        onGoalCompletion = {
            self.client?.objectForKeyedSubscript("connectOperator").callWithArguments([sender])
        }

        self.onInitiateCall?(sender: sender)
    }

    func completeCall(call:[String: AnyObject]) {
        let sender = call["sender"] as! String
        let receiver = call["receiver"] as! String
        print("Completed call from \(sender) to \(receiver)")

        currentGoal = nil
        onGoalCompletion = nil

        self.onCompleteCall?(sender: sender, receiver: receiver)
    }

    func askToConnect(call:[String:AnyObject]) {
        let sender = call["sender"] as! String
        let receiver = call["receiver"] as! String

        print("Asked to connect \(sender) and \(receiver)")

        currentGoal = (sender, receiver)
        onGoalCompletion = {
            self.client?.objectForKeyedSubscript("connect").callWithArguments([sender, receiver])
        }

        self.onAskToConnect?(sender: sender, receiver: receiver)
    }

    //-
    func completeGoal() {
        let block = self.onGoalCompletion
        onGoalCompletion = nil
        currentGoal = nil
        block?()
    }
}