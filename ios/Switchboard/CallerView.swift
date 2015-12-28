import UIKit

@IBDesignable class CallerView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    @IBAction func endDrag(sender: AnyObject, event:UIEvent) {
        self.onDragEnd?(sender: self, event:event)
    }

    var onDragEnd:((sender: CallerView, event:UIEvent) -> Void)?

    var flashTimer:NSTimer?
    var isOn = false;

    func highlight() {
        button.backgroundColor = UIColor.darkGrayColor()
    }

    func unhighlight() {
        button.backgroundColor = UIColor.lightGrayColor()
    }

    func turnOnLight() {
        light.backgroundColor = UIColor.greenColor()
        isOn = true;
    }

    func turnOffLight() {
        light.backgroundColor = UIColor.groupTableViewBackgroundColor()
        isOn = false;
    }

    func startFlashing() {
        flashTimer?.invalidate() // Should never be necessary
        flashTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "flash", userInfo: nil, repeats: true)
    }

    func stopFlashing() {
        flashTimer?.invalidate()
        turnOffLight()
    }

    func flash() {
        if (isOn) {
            turnOffLight()
        } else {
            turnOnLight()
        }
    }

    var connectedTo:CallerView? {
        willSet {
            if newValue != .None {
                highlight()
            } else {
                unhighlight()
            }
        }
    }

    var name:String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }

    // --

    @IBOutlet weak private var contentView:UIView!
    @IBOutlet weak private var light: UIView!

    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        NSBundle(forClass: CallerView.self).loadNibNamed("CallerView", owner: self, options: nil)
        self.addSubview(contentView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": contentView]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views: bindings))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views: bindings))

    }
}
