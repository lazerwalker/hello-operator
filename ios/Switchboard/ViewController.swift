import AVFoundation
import UIKit

typealias DragHandler = ((sender: String, event:UIEvent) -> Void)?
typealias SwitchHandler = ((sender: String, value:SwitchIndex) -> Void)?

protocol Unit : Lightable, Draggable {}

protocol Lightable {
    func turnOnLight(caller:String?)
    func turnOffLight(caller:String?)
    func startFlashing(caller:String?, rate:NSTimeInterval)
}

protocol Draggable {
    var onDragEnd:DragHandler { get set }

    func connectionForName(name:String) -> String?
    func nameForPort(port:UIView) -> String?
    func portForName(name:String) -> UIView?

    func connect(name:String, toOther:String)
    func disconnect(name:String)
}

func == (lhs: Unit?, rhs: Unit?) -> Bool {
    if lhs == nil || rhs == nil { return false }
    if lhs is CallerView && rhs is CallerView &&
        (lhs as! CallerView).name == (rhs as! CallerView).name {
            return true
    } else if lhs is CableView && rhs is CableView &&
        (lhs as! CableView).position == (rhs as! CableView).position {
            return true
    } else {
        return false
    }
}

//-

class ViewController: UIViewController {
    @IBOutlet var callers: [CallerView]!
    @IBOutlet var cables: [CableView]!
    @IBOutlet weak var lineView: LineDrawingView!
    
    let interface = JSInterface()
    let manager = GameManager()

    let synthesizer = AVSpeechSynthesizer()

    var numberOfConnections = 0
    var currentCable:CallerView?
    let numberOfCords = 6

    override func viewDidLoad() {
        super.viewDidLoad()

        for c in callers {
            c.onDragEnd = self.didDrag
        }

        for var i = 0; i < cables.count; i++ {
            let c = cables[i]
            c.onDragEnd = self.didDrag
            c.onSwitch = self.didSwitch
            c.position = i
        }

        interface.onPeopleChange = { people in
            for var i = 0; i < people.count; i++ {
                let view = self.callers[i]
                view.name = people[i]
            }
        }

        interface.onSayToConnect = { sender, receiver in
            let text = "Hello! Can I speak with \(receiver)?"
            let utterance = AVSpeechUtterance(string: text)
            self.synthesizer.speakUtterance(utterance)
            print(text)
        }

        interface.onTurnOn = { caller in
            self.viewForCaller(caller)?.turnOnLight(caller)
        }

        interface.onTurnOff = { caller in
            self.viewForCaller(caller)?.turnOffLight(caller)
        }

        interface.onBlink = { caller, rate in
            self.viewForCaller(caller)?.startFlashing(caller, rate:rate)
        }

        manager.startGame(interface)
    }

    //-
    func didDrag(from:String, event:UIEvent) {
        if let touches = event.allTouches(), touch = touches.first {
            if let view = self.view.hitTest(touch.locationInView(self.view), withEvent: nil) {
                // TODO: This is silly.
                if let grandparent = view.superview?.superview as? Unit {
                    if let to = grandparent.nameForPort(view) {
                        self.drewLineBetween(from, to)
                    }
                }
            }
        }
    }

    func drewLineBetween(first:String, _ second:String) {
        if let firstObj = self.viewForCaller(first),
            secondObj = self.viewForCaller(second) {
                let firstConnection = firstObj.connectionForName(first)
                let secondConnection = secondObj.connectionForName(second)

                if firstConnection == nil && secondConnection == nil {
                    connect(first, second)
                } else if firstConnection == second {
                    disconnect(first, second)
                } else if firstConnection != nil && secondConnection == nil {
                    if let other = firstConnection {
                        disconnect(first, other)
                        connect(second, other)
                    }
                }
        }
    }

    //-

    func didSwitch(cable:String, value:SwitchIndex) {
        interface.toggleSwitch(cable, state: value)
    }

    //-

    private func connect(first:String, _ second:String) {
        if let firstObj = self.viewForCaller(first),
            secondObj = self.viewForCaller(second) {
                if firstObj is CableView {
                    interface.connect(first, second)
                } else if secondObj is CableView {
                    interface.connect(second, first)
                }

                firstObj.connect(first, toOther: second)
                secondObj.connect(second, toOther:first)

                if let firstView = firstObj.portForName(first),
                    secondView = secondObj.portForName(second) {
                        lineView.addLine(firstView, secondView)
                }
        }
    }

    private func disconnect(first:String, _ second:String) {
        if let firstObj = self.viewForCaller(first),
            secondObj = self.viewForCaller(second) {
                interface.disconnect(first, second)

                firstObj.disconnect(first)
                secondObj.disconnect(second)

                if let firstView = firstObj.portForName(first),
                    secondView = secondObj.portForName(second) {
                        lineView.removeLine(firstView, secondView)
                }
        }
    }

    private func viewForCaller(caller:String?) -> Unit? {
        if let c = caller {
            if c.rangeOfString("cable") != nil {
                if let number = Int(String(c[c.startIndex.advancedBy(5)])) {
                    return self.cables[number]
                }
            } else if let index = self.interface.people.indexOf(c) {
                return self.callers[index]
            }
        }
        return nil
    }
}

