import UIKit

@IBDesignable class CallerView: UIView, Lightable {
    @IBOutlet weak private var contentView:UIView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
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

    //-
    @IBAction func endDrag(sender: AnyObject, event:UIEvent) {
        if let name = name {
            self.onDragEnd?(sender: name, event:event)
        }
    }

    var onDragEnd:((sender: String, event:UIEvent) -> Void)?

    var flashTimer:NSTimer?
    var isOn = false;

    func highlight() {
        button.backgroundColor = UIColor.darkGrayColor()
    }

    func unhighlight() {
        button.backgroundColor = UIColor.lightGrayColor()
    }

    func turnOnLight(caller:String?) {
        self.turnOnLight(caller, isFlash: false)
    }

    private func turnOnLight(caller:String?, isFlash:Bool) {
        light.backgroundColor = UIColor.greenColor()
        isOn = true;

        if (!isFlash) {
            flashTimer?.invalidate()
        }
    }

    func turnOffLight(caller:String?) {
        self.turnOffLight(caller, isFlash: false)
    }

    private func turnOffLight(caller:String?, isFlash:Bool) {
        light.backgroundColor = UIColor.groupTableViewBackgroundColor()
        isOn = false;

        if (!isFlash) {
            flashTimer?.invalidate()
        }
    }

    func startFlashing(caller:String?, rate:NSTimeInterval = 0) {
        flashTimer?.invalidate()
        if (rate == 0) {
            turnOnLight(nil)
            return
        }

        flashTimer = NSTimer.scheduledTimerWithTimeInterval(rate, target: self, selector: "flash", userInfo: nil, repeats: true)
    }

    func stopFlashing() {
        flashTimer?.invalidate()
        turnOffLight(nil)
    }

    func flash() {
        if (isOn) {
            turnOffLight(nil, isFlash: true)
        } else {
            turnOnLight(nil, isFlash: true)
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
}
