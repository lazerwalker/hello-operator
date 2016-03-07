import Foundation

enum SwitchIndex: Int {
    case Talk = -1, Neutral, Ring
}

protocol GameInterface {
    func startGame()

    var onTurnOn:((String) -> Void)? {get set}
    var onTurnOff:((String) -> Void)? {get set}
    var onBlink:((String, NSTimeInterval) -> Void)? {get set}
    var onPeopleChange:(([String]) -> Void)? {get set}
    var onSayToConnect:((sender: String, receiver:String) -> Void)? {get set}
}