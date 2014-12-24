//
//  PopUpView.swift
//  remember
//
//  Created by Joseph Cheung on 12/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

protocol PopUpViewDelegate {
    func closeButtonPressed()
}

@IBDesignable
class PopUpView: UIView {

    lazy var frameView: UIView! = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.whiteColor()
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 5.0
        view.clipsToBounds = true
        
        return view
        }()
    
    lazy var overlayView: UIScrollView! = {
        let view = UIScrollView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        return view
        }()
    
    lazy var closeButton: UIButton! = {
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "closeButtonPressed", forControlEvents: .TouchUpInside)
        return button
        }()
    
    var buttonImage: UIImage? {
        didSet {
            closeButton.setImage(buttonImage, forState: .Normal)
        }
    }
    
    var popUpDelegate: PopUpViewDelegate?
    var frameViewTopConstraint: NSLayoutConstraint?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        addSubview(overlayView)
        overlayView.addSubview(frameView)
        overlayView.insertSubview(closeButton, aboveSubview: frameView)
        
        buttonImage = UIImage(named: "close")
        
        let frameTopSpacing = frame.size.height / 10.0
        let metricsDict = ["frameTopSpacing": frameTopSpacing]
        
        let viewsDict = ["frameView": frameView, "overlayView": overlayView]
        
        let topConstraint = NSLayoutConstraint(item: frameView, attribute: .Top, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: self, attribute: .Top, multiplier: 1, constant: 50)

        let centerXConstraint = NSLayoutConstraint(item: frameView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: frameView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.75, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: frameView, attribute: .Height, relatedBy: .Equal, toItem: frameView, attribute: .Width, multiplier: 615/555.0, constant: 0)
        
        frameViewTopConstraint = topConstraint

        frameView.addConstraint(heightConstraint)
        addConstraints([centerXConstraint, widthConstraint, topConstraint])
        
        let buttonCenterXConstraint = NSLayoutConstraint(item: closeButton, attribute: .CenterX, relatedBy: .Equal, toItem: frameView, attribute: .Trailing, multiplier: 0.96, constant: 0)
        let buttonCenterYConstraint = NSLayoutConstraint(item: closeButton, attribute: .CenterY, relatedBy: .Equal, toItem: frameView, attribute: .Top, multiplier: 1.04, constant: 0)
        let buttonWidthConstraint = NSLayoutConstraint(item: closeButton, attribute: .Width, relatedBy: .Equal, toItem: frameView, attribute: .Width, multiplier: 0.2, constant: 0)
        let buttonHeightConstraint = NSLayoutConstraint(item: closeButton, attribute: .Height, relatedBy: .Equal, toItem: closeButton, attribute: .Width, multiplier: 1, constant: 0)
        
        closeButton.addConstraint(buttonHeightConstraint)
        addConstraints([buttonCenterXConstraint, buttonCenterYConstraint, buttonWidthConstraint])
        
        let overlayViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[overlayView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        let overlayViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[overlayView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        
        addConstraints(overlayViewHorizontalConstraints)
        addConstraints(overlayViewVerticalConstraints)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let bundle = NSBundle(forClass: self.dynamicType)
        let image = UIImage(named: "close", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)
        buttonImage = image
    }
    
    func closeButtonPressed() {
        popUpDelegate?.closeButtonPressed()
    }
}
