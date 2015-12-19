import AVFoundation
import UIKit

class ViewController: UIViewController {
    @IBOutlet var callers: [CallerView]!
    @IBOutlet weak var operatorView: CallerView!

    let interface = JSInterface()
    let manager = GameManager()

    let synthesizer = AVSpeechSynthesizer()

    var connections:[(CallerView?, CallerView?)] = [] {
        didSet {
            self.checkConnections()
        }
    }
    let numberOfCords = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        for c in callers {
            c.onTap = self.didTapCaller
        }

        operatorView.onTap = self.didTapCaller
        operatorView.name = "OPER"

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

        manager.startGame(interface)
    }

    //-
    func didTapCaller(caller:CallerView) {
        let containing = connections.filter { $0.0 == caller || $0.1 == caller }
        if containing.count == 1 {
            caller.unhighlight()
            caller.connected = nil

            if let (first, second) = containing.first {
                let index = connections.indexOf { $0.0 == caller || $0.1 == caller }
                connections.removeAtIndex(index!)

                let other = (first == caller ? second : first)
                if other != nil {
                    other?.connected = nil
                    let new:(CallerView?, CallerView?) = (other, Optional.None as CallerView?)
                    connections.append(new)
                }
            }
        } else {
            if let pairIndex = connections.indexOf({ $0.1 == .None }) {
                caller.highlight()

                let other = connections.filter({ $0.1 == .None }).first!.0
                connections.removeAtIndex(pairIndex)
                other?.connected = callerForView(caller)
                caller.connected = callerForView(other!)
                let new:(CallerView?, CallerView?) = (other, caller)
                connections.append(new)
            } else if connections.count < numberOfCords {
                caller.highlight()

                let new:(CallerView?, CallerView?) = (caller, Optional.None as CallerView?)
                connections.append(new)
            }
        }
    }

    //-

    func checkConnections() {
        let namedConnections = connections.map { (callerForView($0.0), callerForView($0.1)) }
        if let goal = interface.currentGoal {
            if namedConnections.contains({
                ($0.0 == goal.0 && $0.1 == goal.1) }) {
                    interface.completeGoal()
            } else if namedConnections.contains({
                ($0.0 == goal.1 && $0.1 == goal.0) }) {
                    interface.completeGoal()
            }
        }
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

    private func callerForView(view:CallerView?) -> String? {
        if let view = view {
            if view == self.operatorView {
                return "OPER"
            }

            if let index = self.callers.indexOf(view) {
                return self.interface.people[index]
            }
        }
        return nil
    }
}

