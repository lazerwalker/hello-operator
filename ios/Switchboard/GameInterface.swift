import Foundation

enum SwitchIndex: Int {
    case Talk = -1, Neutral, Ring
}

protocol GameInterface {
    var people: [String] { get set }

    func connect(first:String, _ second:String)
    func disconnect(first:String, _ second:String)
    func toggleSwitch(cable:String, state:SwitchIndex)
    func startGame()

    //-
    var onTurnOn:((String) -> Void)? {get set}
    var onTurnOff:((String) -> Void)? {get set}
    var onBlink:((String, NSTimeInterval) -> Void)? {get set}
    var onPeopleChange:(([String]) -> Void)? {get set}
    var onSayToConnect:((sender: String, receiver:String) -> Void)? {get set}

    var onConnect:((cable: String, port:String) -> Void)? {get set}
    var onDisconnect:((cable: String, port:String) -> Void)? {get set}
    var onToggleSwitch:((switchNum: String, position:SwitchIndex) -> Void)? {get set}
}