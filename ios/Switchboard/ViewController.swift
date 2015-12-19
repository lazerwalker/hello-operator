import AVFoundation
import UIKit

class ViewController: UIViewController {
    @IBOutlet var callers: [CallerView]!
    @IBOutlet weak var operatorView: CallerView!

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

        operatorView.name = interface.OPERATOR
        operatorView.onDragEnd = self.didDrag

        interface.onPeopleChange = { people in
            for var i = 0; i < people.count; i++ {
                let view = self.callers[i]
                view.name = people[i]
            }
        }

        interface.onInitiateCall = { caller in
            self.viewForCaller(caller)?.turnOnLight()
        }

        interface.onAskToConnect = { sender, receiver in
            self.viewForCaller(sender)?.turnOffLight()
            let text = "Hello! Can I speak with \(receiver)?"
            let utterance = AVSpeechUtterance(string: text)
            self.synthesizer.speakUtterance(utterance)
        }

        interface.onAskToDisconnect = { sender, receiver in }

        manager.startGame(interface)
    }

    //-
    func didDrag(from:CallerView, event:UIEvent) {
        if let touches = event.allTouches(), touch = touches.first {
            if let view = self.view.hitTest(touch.locationInView(self.view), withEvent: nil) {
                // TODO: This is silly.
                if let grandparent = view.superview?.superview {
                    if grandparent.isKindOfClass(CallerView.self) {
                        let to = grandparent as! CallerView
                        self.drewLineBetween(from, to)
                    }
                }
            }
        }
    }

    func drewLineBetween(first:CallerView, _ second:CallerView) {
        // TODO: Track number of cords
        if first.connectedTo == second {
            // They're connected, disconnect them
            first.connectedTo = nil;
            second.connectedTo = nil;

            if let firstName = first.name, secondName = second.name {
                interface.disconnect(firstName, secondName)
            }
        } else if first.connectedTo == nil && second.connectedTo == nil {
            // Both are unconnected, connect 'em
            first.connectedTo = second
            second.connectedTo = first

            if let firstName = first.name, secondName = second.name {
                interface.connect(firstName, secondName)
            }
        }
        // TODO: Moving one end to another plug
    }

    //-

    private func viewForCaller(caller:String) -> CallerView? {
        if caller == "OPER" {
            return self.operatorView
        }

        if let index = self.interface.people.indexOf(caller) {
            return self.callers[index]
        }
        return nil
    }
}

