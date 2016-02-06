import UIKit

@IBDesignable class CableView: UIView, Lightable {
    @IBOutlet weak var rearCable: UIButton!
    @IBOutlet weak var frontCable: UIButton!

    @IBOutlet weak var rearLight: UIView!
    @IBOutlet weak var frontLight: UIView!
    
    @IBOutlet weak var frontSwitch: UISegmentedControl!
    @IBOutlet weak var rearSwitch: UISegmentedControl!

    @IBOutlet weak private var contentView:UIView!

    var onDragEnd:((sender: String, event:UIEvent) -> Void)?

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


    @IBAction func didEndRearDrag(sender: AnyObject) {
    }

    @IBAction func didEndFrontDrag(sender: AnyObject) {
    }

    @IBAction func didToggleRearSwitch(sender: AnyObject) {
    }

    @IBAction func didToggleFrontSwitch(sender: AnyObject) {
    }

    //-
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
