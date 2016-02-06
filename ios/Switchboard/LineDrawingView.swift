//
//  LineDrawingView.swift
//  Switchboard
//
//  Created by Mike Lazer-Walker on 12/19/15.
//  Copyright © 2015 Mike Lazer-Walker. All rights reserved.
//

import UIKit

class LineDrawingView: UIView {
    var lines:[(UIView, UIView)] = []

    func addLine(first:UIView, _ second:UIView) {
        lines.append((first, second))
        setNeedsDisplay()
    }

    func removeLine(first:UIView, _ second:UIView) {
        lines = lines.filter { (a, b) -> Bool in
            if (first == a && second == b) {
                return false
            } else if (first == b && second == a) {
                return false
            } else {
                return true
            }
        }

        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, UIColor.darkGrayColor().CGColor)
        CGContextSetLineWidth(context, 4.0)

        lines.forEach { (first, second) -> () in
            let firstCenter = self.convertPoint(first.center, fromView: first.superview!)
            let secondCenter = self.convertPoint(second.center, fromView: second.superview!)

            CGContextMoveToPoint(context, firstCenter.x, firstCenter.y)
            CGContextAddLineToPoint(context, secondCenter.x, secondCenter.y)
            CGContextStrokePath(context)
        }
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return nil
    }
}
