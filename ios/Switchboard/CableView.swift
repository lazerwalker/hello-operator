import UIKit

@IBDesignable class CableView: UIView, Unit {
    @IBOutlet weak var rearCable: UIButton!
    @IBOutlet weak var frontCable: UIButton!

    @IBOutlet weak var rearLight: UIView!
    @IBOutlet weak var frontLight: UIView!
    
    @IBOutlet weak var frontSwitch: UISegmentedControl!
    @IBOutlet weak var rearSwitch: UISegmentedControl!

    @IBOutlet weak private var contentView:UIView!

    var position:Int?
    var onDragEnd:DragHandler
    var onSwitch:SwitchHandler

    var frontConnection:String? {
        willSet {
            if newValue != nil {
                frontCable.backgroundColor = UIColor.darkGrayColor()
            } else {
                frontCable.backgroundColor = UIColor.lightGrayColor()
            }
        }
    }

    var rearConnection:String? {
        willSet {
            if newValue != nil {
                rearCable.backgroundColor = UIColor.darkGrayColor()
            } else {
                rearCable.backgroundColor = UIColor.lightGrayColor()
            }
        }
    }

    var rearName:String? {
        get {
            if let position = position {
                return "cable\(position)R"
            } else {
                return nil
            }
        }
    }

    var frontName:String? {
        get {
            if let position = position {
                return "cable\(position)F"
            } else {
                return nil
            }
        }
    }


    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        NSBundle(forClass: CableView.self).loadNibNamed("CableView", owner: self, options: nil)
        self.addSubview(contentView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": contentView]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views: bindings))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views: bindings))
    }

    //-
    // Draggable

    func nameForPort(port: UIView) -> String? {
        if port == frontCable {
            return frontName
        } else if port == rearCable {
            return rearName
        } else {
            return nil
        }
    }

    func portForName(name: String) -> UIView? {
        if name == frontName {
            return frontCable
        } else if name == rearName {
            return rearCable
        } else {
            return nil
        }
    }


    func connectionForName(name: String) -> String? {
        if name == frontName {
            return frontConnection
        } else if name == rearName {
            return rearConnection
        } else {
            return nil
        }
    }

    func connect(name: String, toOther other: String) {
        if name == frontName {
            frontConnection = other
        } else if name == rearName {
            rearConnection = other
        }
    }

    func disconnect(name: String) {
        if name == frontName {
            frontConnection = nil
        } else if name == rearName {
            rearConnection = nil
        }
    }

    @IBAction func didEndRearDrag(sender: AnyObject, forEvent event: UIEvent) {
        if let sender = rearName {
            self.onDragEnd?(sender: sender, event: event)
        }
    }

    @IBAction func didEndFrontDrag(sender: AnyObject, forEvent event: UIEvent) {
        if let sender = frontName {
            self.onDragEnd?(sender: sender, event: event)
        }
    }

    private func segmentedControlIndexToSwitchIndex(value:Int) -> SwitchIndex {
        var newValue:SwitchIndex
        switch value {
            case 0: newValue = .Talk
            case 1: newValue = .Neutral
            case 2: newValue = .Ring
            default: newValue = .Neutral
        }

        return newValue
    }

    @IBAction func didToggleFrontSwitch(sender: UISegmentedControl) {
        if let name = frontName {
            let changed = sender.selectedSegmentIndex
            let value = segmentedControlIndexToSwitchIndex(changed)
            self.onSwitch?(sender: name, value: value)
        }
    }

    @IBAction func didToggleRearSwitch(sender: AnyObject) {
        if let name = rearName {
            let changed = sender.selectedSegmentIndex
            let value = segmentedControlIndexToSwitchIndex(changed)
            self.onSwitch?(sender: name, value: value)
        }
    }

    //-
    // Lightable
    func turnOnLight(caller:String?) {
        if let caller = caller {
            let isFront = caller[caller.endIndex.predecessor()] == "F"
            let light = (isFront ? frontLight : rearLight)
            light.backgroundColor = UIColor.greenColor()
        }
    }

    func turnOffLight(caller:String?) {
        if let caller = caller {
            let isFront = caller[caller.endIndex.predecessor()] == "F"
            let light = (isFront ? frontLight : rearLight)
            light.backgroundColor = UIColor.groupTableViewBackgroundColor()
        }
    }

    func startFlashing(caller:String?, rate:NSTimeInterval = 0) {
        // TODO: I don't think cables actually need flashing?
    }
}
