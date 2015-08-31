import UIKit

class ViewController: UIViewController {
    @IBOutlet var callers: [CallerView]!
    @IBOutlet weak var operatorView: CallerView!

    let interface:JSInterface
    let manager:GameManager

    var connections:[(CallerView?, CallerView?)] = []
    let numberOfCords = 2

    required init(coder aDecoder: NSCoder) {
        interface = JSInterface()
        manager = GameManager()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for c in callers {
            c.onTap = self.didTapCaller
        }

        interface.onPeopleChange = { people in
            for var i = 0; i < people.count; i++ {
                let view = self.callers[i]
                view.name = people[i]
            }
        }

        interface.onInitiateCall = { caller in
            self.viewForCaller(caller)?.turnOnLight()
        }

        manager.startGame(interface)
    }

    //-
    func didTapCaller(caller:CallerView) {
        print(connections)
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

    private func viewForCaller(caller:String) -> CallerView? {
        if let index = self.interface.people.indexOf(caller) {
            return self.callers[index]
        }
        return nil
    }

    private func callerForView(view:CallerView) -> String? {
        if let index = self.callers.indexOf(view) {
            return self.interface.people[index]
        }
        return nil
    }
}

