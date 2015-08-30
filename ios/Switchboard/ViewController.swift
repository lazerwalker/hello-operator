import UIKit

class ViewController: UIViewController {
    @IBOutlet var callers: [CallerView]!
    @IBOutlet weak var operatorView: CallerView!

    let interface:JSInterface
    let manager:GameManager

    required init(coder aDecoder: NSCoder) {
        interface = JSInterface()
        manager = GameManager()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

    private func viewForCaller(caller:String) -> CallerView? {
        if let index = self.interface.people.indexOf(caller) {
            return self.callers[index]
        }
        return nil
    }
}

