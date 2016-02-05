import UIKit

@IBDesignable class CableView: UIView {
    @IBOutlet weak var rearCable: UIButton!
    @IBOutlet weak var frontCable: UIButton!

    @IBOutlet weak var rearLight: UIView!
    @IBOutlet weak var frontLight: UIView!
    
    @IBOutlet weak var frontSwitch: UISegmentedControl!
    @IBOutlet weak var rearSwitch: UISegmentedControl!

    @IBOutlet weak private var contentView:UIView!

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
}
