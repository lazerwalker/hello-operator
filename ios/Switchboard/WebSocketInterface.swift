import Foundation
import Starscream

class WebSocketInterface : GameInterface, WebSocketDelegate {
    var onTurnOn:((String) -> Void)?
    var onTurnOff:((String) -> Void)?
    var onBlink:((String, NSTimeInterval) -> Void)?
    var onPeopleChange:(([String]) -> Void)?
    var onSayToConnect:((sender: String, receiver:String) -> Void)?

    let url:NSURL
    let socket:WebSocket

    required init(url:NSURL) {
        self.url = url
        self.socket = WebSocket(url: url)

        socket.delegate = self
        socket.connect()
    }

    dynamic var people:[String] = [] {
        didSet {
            self.onPeopleChange?(self.people)
        }
    }

    func startGame() {
        // TODO: I think this can be a no-op?
    }

    func turnOnLight(sender: String) {
        print("Turning on \(sender)")
        self.onTurnOn?(sender)
    }

    func turnOffLight(sender: String) {
        print("Turning off \(sender)")
        self.onTurnOff?(sender)
    }

    func blinkLight(caller:String, rate:Double) {
        print("Blinking \(caller), \(rate)")
        let interval:NSTimeInterval = rate / 1000
        self.onBlink?(caller, interval)
    }

    func sayToConnect(sender:String, _ receiver: String) {
        self.onSayToConnect?(sender: sender, receiver: receiver)
    }

    //-
    // Called from view controller
    func connect(first:String, _ second:String) {
        self.socket.writeString("connect,\(first),\(second)")
    }

    func disconnect(first:String, _ second:String) {
        self.socket.writeString("disconnect,\(first),\(second)")
    }

    func toggleSwitch(cable:String, state:SwitchIndex) {
        self.socket.writeString("toggleSwitch,\(cable),\(state.rawValue)")
    }

    //-
    // WebSocketDelegate
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {}

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let splitText = text.componentsSeparatedByString(",")
        if let command = splitText.first {
            switch(command) {
                case "turnOnLight":
                    turnOnLight(splitText.last!)
                case "turnOffLight":
                    turnOffLight(splitText.last!)
                case "blinkLight":
                    let caller = splitText[1]
                    if let rate = Double(splitText[2]) {
                        blinkLight(caller, rate: rate)
                    }
                case "sayToConnect":
                    sayToConnect(splitText[1], splitText[2])
                case "people":
                    let people = splitText[1..<splitText.count]
                    self.people = Array(people)
                default:
                    print("Ignoring unknown message: '\(text)'")
            }
        }
    }

    func websocketDidConnect(socket: WebSocket) { }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) { }
}