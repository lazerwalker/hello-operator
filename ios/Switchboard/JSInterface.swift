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
    dynamic var people: [String]
    dynamic var client: JSValue?

    override init() {
        self.people = []
    }

    func initiateCall(sender: String) {
        print("\(sender) is calling!")
    }

    func completeCall(sender: String, receiver: String) {
        print("Completed call from \(sender) to \(receiver)")
    }

    func askToConnect(sender: String, receiver: String) {
        puts("Asked to connect \(sender) and \(receiver)")
    }
}