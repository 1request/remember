//
//  UnreadSpotView.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

@IBDesignable class UnreadSpotView: UIView {
    
    let spotSize: CGFloat = 12
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        UIColor.clearColor().setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect)

        // Drawing code
        var spotPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, spotSize, spotSize))
        var spotColor = UIColor.appBlueColor()
        
        spotColor.setFill()
        spotPath.fill()
    }

}
