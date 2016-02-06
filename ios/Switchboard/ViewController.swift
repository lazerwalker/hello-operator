import AVFoundation
import UIKit

protocol Lightable {
    func turnOnLight(caller:String?)
    func turnOffLight(caller:String?)
    func startFlashing(caller:String?, rate:NSTimeInterval)
}

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

        for c in cables {
            c.onDragEnd = self.didDrag
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
                if let grandparent = view.superview?.superview {
                    if grandparent.isKindOfClass(CallerView.self) {
//                        let to = grandparent as! CallerView
//                        self.drewLineBetween(from, to)
                    }
                }
            }
        }
    }

    func drewLineBetween(first:CallerView, _ second:CallerView) {
        // TODO: Track number of cords
        if first.connectedTo == second {
            disconnect(first, second)
        } else if first.connectedTo == nil && second.connectedTo == nil {
            connect(first, second)
        } else if first.connectedTo != nil && second.connectedTo == nil {
            if let other = first.connectedTo {
                disconnect(first, other)
                connect(second, other)
            }
        }
    }

    //-

    private func connect(first:CallerView, _ second:CallerView) {
        first.connectedTo = second
        second.connectedTo = first
        lineView.addLine(first, second)

        if let firstName = first.name, secondName = second.name {
            interface.connect(firstName, secondName)
        }
    }

    private func disconnect(first:CallerView, _ second:CallerView) {
        first.connectedTo = nil;
        second.connectedTo = nil;
        lineView.removeLine(first, second)

        if let firstName = first.name, secondName = second.name {
            interface.disconnect(firstName, secondName)
        }
    }

    private func viewForCaller(caller:String?) -> Lightable? {
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

