//
//  HUD.swift
//  remember
//
//  Created by Joseph Cheung on 6/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class HUD: UIView {

    internal var text = ""
    private weak var parentView:UIView?
    private var timer: NSTimer? = nil
    private lazy var tileWidth: CGFloat = {
        [unowned self] in
        return self.bounds.size.width / 16
    }()
    private lazy var tileHeight: CGFloat = {
        [unowned self] in
        return self.tileWidth / 5
    }()
    private lazy var tileSpacing: CGFloat = {
        [unowned self] in
        return self.tileHeight / 2
    }()

    private let lowerBound = 1
    private let upperBound = 5
    private let tileColumns = 3
    
    class func hudInView(view: UIView) -> HUD {
        let hudView = HUD(frame: view.bounds)
        hudView.opaque = false
        hudView.parentView = view
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        hudView.showAnimated()
        hudView.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: hudView, selector: "setNeedsDisplay", userInfo: nil, repeats: true)
        return hudView
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let radius = bounds.size.width / 4
        let circleRect = CGRectMake(radius, bounds.size.height / 2 - radius, radius * 2, radius * 2)
        let circularPath = UIBezierPath(ovalInRect: circleRect)
        UIColor.appGrayColor().setFill()
        circularPath.fill()
        let font = UIFont.boldSystemFontOfSize(16.0)
        let textSize = (text as NSString).sizeWithAttributes([NSFontAttributeName: font])
        let textPoint =  CGPointMake(center.x - textSize.width / 2, center.y - textSize.height / 2 + radius / 4)
        (text as NSString).drawAtPoint(textPoint, withAttributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()])
        randomTiles()
    }
    
    private func showAnimated() {
        alpha = 0.0
        transform = CGAffineTransformMakeScale(1.3, 1.3)
        
        UIView.animateWithDuration(0.4) {
            self.alpha = 1.0
            self.transform = CGAffineTransformIdentity
        }
    }
    
    private func randomTileNumber() -> Int {
        let rand = UInt32(upperBound - lowerBound + 1)
        return lowerBound + Int(arc4random_uniform(rand))
    }
    
    private func randomTiles() {
        for tileColumn in 0..<3 {
            let numberOfTiles = randomTileNumber()
            for tileIndex in 0..<numberOfTiles {
                drawTileAtIndex(tileIndex, AtTileColumn: tileColumn)
            }
        }
    }
    
    private func drawTileAtIndex(tileIndex: Int, AtTileColumn tileColumn: Int) {
        var x:CGFloat = 0.0
        switch tileColumn {
        case 0:
            x = center.x - tileWidth / 2 - tileWidth - tileSpacing
        case 1:
            x = center.x - tileWidth / 2
        case 2:
            x = center.x + tileWidth / 2 + tileSpacing
        default: ()
        }
        let y = center.y + tileHeight - CGFloat(tileIndex) * (tileHeight + tileSpacing)
        let tileRect = CGRectMake(x, y, tileWidth, tileHeight)
        let tilePath = UIBezierPath(rect: tileRect)
        UIColor.whiteColor().setFill()
        tilePath.fill()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        parentView?.userInteractionEnabled = true
        timer?.invalidate()
        timer = nil
    }
}
