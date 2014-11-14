//
//  RadioButton.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

@IBDesignable class RadioButton: UIView {
    
    let strokeWidth: CGFloat = 1
    let buttonSize: CGFloat = 24

    var _checked: Bool = false

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        UIColor.clearColor().setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
        
        let width = frame.size.width - (strokeWidth * 2)
        let height = frame.size.height - (strokeWidth * 2)
        
        // Drawing code
        var outterCirclePath = UIBezierPath(ovalInRect: CGRectMake(strokeWidth, strokeWidth, width, height))
        var outterCircleColor = UIColor.appGrayColor()
        
        outterCircleColor.setStroke()
        outterCirclePath.lineWidth = 1
        outterCirclePath.stroke()
        
        if _checked {
            let x = frame.size.width / 8
            let y = frame.size.height / 8
            let width = frame.size.width * 3 / 4
            let height = frame.size.height * 3 / 4
            
            var innerCirclePath = UIBezierPath(ovalInRect: CGRectMake(x, y, width, height))
            var innerCircleColor = UIColor.appBlueColor()
            
            innerCircleColor.setFill()
            innerCirclePath.fill()
        }
    }
    
    func setChecked(checked: Bool) {
        _checked = checked
        
        setNeedsDisplay()
    }

}
