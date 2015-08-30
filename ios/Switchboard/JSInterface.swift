import Foundation
import JavaScriptCore

@objc protocol JSInterfaceExports : JSExport {
    var people: [String] { get set }
    var client: JSValue? { get set }

    func initiateCall(sender:String)
    func completeCall(sender:String, receiver:String)
    func askToConnect(sender:String, receiver:String)
}

// Custom class must inherit from `NSObject`
@objc class JSInterface : NSObject, JSInterfaceExports {
    var onInitiateCall:((sender: String) -> Void)?
    var onCompleteCall:((sender: String, receiver:String) -> Void)?
    var onAskToConnect:((sender: String, receiver:String) -> Void)?
    var onPeopleChange:(([String]) -> Void)?

    dynamic var people:[String] = [] {
        didSet {
            self.onPeopleChange?(self.people)
        }
    }
    
    dynamic var client: JSValue?

    func initiateCall(sender: String) {
        print("\(sender) is calling!")
        self.onInitiateCall?(sender: sender)
    }

    func completeCall(sender: String, receiver: String) {
        print("Completed call from \(sender) to \(receiver)")
        self.onCompleteCall?(sender: sender, receiver: receiver)
    }

    func askToConnect(sender: String, receiver: String) {
        puts("Asked to connect \(sender) and \(receiver)")
        self.onAskToConnect?(sender: sender, receiver: receiver)
    }
}