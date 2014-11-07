//
//  SwipeableTableViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 3/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

//MARK: - SwipeableTableViewCellDataSource
@objc protocol SwipeableTableViewCellDataSource {
    func numberOfButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int
    
    optional func swipeableCell(cell: SwipeableTableViewCell, buttonForIndex index: Int) -> UIButton?
    optional func swipeableCell(cell: SwipeableTableViewCell, titleForButtonAtIndex index: Int) -> String?
    optional func swipeableCell(cell: SwipeableTableViewCell, backgroundColorForButtonAtIndex index: Int) -> UIColor?
    optional func swipeableCell(cell: SwipeableTableViewCell, tintColorForButtonAtIndex index: Int) -> UIColor?
    optional func swipeableCell(cell: SwipeableTableViewCell, backgroundImageForButtonAtIndex index: Int) -> UIImage?
    optional func swipeableCell(cell: SwipeableTableViewCell, fontForButtonAtIndex index: Int) -> UIFont?
}

//MARK: - SwipeableTableViewCellDelegate

@objc protocol SwipeableTableViewCellDelegate {
    func swipeableCell(cell: SwipeableTableViewCell, didSelectButtonAtIndex index: Int)
    func swipeableCellDidOpen(cell: SwipeableTableViewCell)
    func swipeableCellDidClose(cell: SwipeableTableViewCell)
}


//MARK: - SwipeableTableViewCell Class

class SwipeableTableViewCell: UITableViewCell, UIGestureRecognizerDelegate {
    var opened = false
    
    var customContentView = UIView()
    weak var delegate: SwipeableTableViewCellDelegate?
    weak var dataSource: SwipeableTableViewCellDataSource?
    
    var buttons: [UIButton] = []
    private var panStartPoint = CGPointZero
    private var startingRightLayoutConstraintConstant: CGFloat = 0
    private var contentViewRightConstraint: NSLayoutConstraint?
    private var contentViewLeftConstraint: NSLayoutConstraint?
    
    //MARK: - Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        selectionStyle = UITableViewCellSelectionStyle.None
        customContentView.userInteractionEnabled = true
        customContentView.clipsToBounds = true
        customContentView.backgroundColor = UIColor.whiteColor()
        customContentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        contentView.addSubview(customContentView)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panThisCell:")
        panRecognizer.delegate = self
        customContentView.addGestureRecognizer(panRecognizer)
        layoutIfNeeded()
    }
    
    override init() {
        super.init()
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    //MARK: - Cell Lifecycle
    
    override func updateConstraints() {
        super.updateConstraints()
        if contentViewRightConstraint == nil {
            let dict = ["customContentView": customContentView]
            let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[customContentView]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: dict)
            contentView.addConstraints(verticalConstraints)
            
            let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[customContentView]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: dict)
            
            contentViewLeftConstraint = horizontalConstraints[0] as? NSLayoutConstraint
            contentViewRightConstraint = horizontalConstraints[1] as? NSLayoutConstraint
            
            contentView.addConstraints(horizontalConstraints)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetConstraintContstantsToZero(false, notifyDelegateDidClose: false)
        
        for button in buttons {
            button.removeFromSuperview()
        }
        
        buttons.removeAll(keepCapacity: false)
    }
    
    //MARK: - Button Config
    
    private func configureButtons() {
        var previousMinX = CGRectGetWidth(frame)
        if let numberOfButtons = dataSource?.numberOfButtonsInSwipeableCell(self) {
            for i in 0..<numberOfButtons {
                let button = buttonForIndex(i, previousButtonMinX: previousMinX)
                buttons.append(button)
                previousMinX -= CGRectGetWidth(button.frame)
                contentView.addSubview(button)
            }
            contentView.bringSubviewToFront(customContentView)
        }
    }
    
    
    private func configureButtonsIfNeeded() {
        if buttons.count == 0 {
            configureButtons()
        }
    }
    
    private func buttonForIndex(index: Int, previousButtonMinX previousMinX: CGFloat) -> UIButton {
        var button = UIButton()
        
        if let customButton = dataSource?.swipeableCell?(self, buttonForIndex: index) {
            button = customButton
        } else {
            if let title = dataSource?.swipeableCell?(self, titleForButtonAtIndex: index) {
                button.setTitle(title, forState: UIControlState.Normal)
            } else {
                button.setTitle("", forState: UIControlState.Normal)
            }
            
            if let image = dataSource?.swipeableCell?(self, backgroundImageForButtonAtIndex: index) {
                button.setBackgroundImage(image, forState: UIControlState.Normal)
                button.frame.size.width = image.size.width / image.size.height * frame.height
            }
            
            if let tintColor = dataSource?.swipeableCell?(self, tintColorForButtonAtIndex: index) {
                button.tintColor = tintColor
            } else {
                button.tintColor = UIColor.whiteColor()
            }
            
            if let font = dataSource?.swipeableCell?(self, fontForButtonAtIndex: index) {
                button.titleLabel?.font = font
            }
            
            if let backgroundColor = dataSource?.swipeableCell?(self, backgroundColorForButtonAtIndex: index) {
                button.backgroundColor = backgroundColor
            } else {
                if dataSource?.swipeableCell?(self, backgroundImageForButtonAtIndex: index) == nil {
                    if index == 0 {
                        button.backgroundColor = UIColor.redColor()
                    } else {
                        button.backgroundColor = UIColor.lightGrayColor()
                    }
                }
            }
            
            if (dataSource?.swipeableCell?(self, backgroundImageForButtonAtIndex: index) == nil) {
                button.sizeToFit()
            }
            
            let appleRecommendedMinimumTouchPointWidth = 44.0 as CGFloat
            
            if button.frame.size.width < appleRecommendedMinimumTouchPointWidth {
                var frame = button.frame
                frame.size.width = appleRecommendedMinimumTouchPointWidth
                button.frame = frame
            }
        }
        
        let xOrigin = previousMinX - CGRectGetWidth(button.frame)
        
        button.frame = CGRectMake(xOrigin, 0, CGRectGetWidth(button.frame), CGRectGetHeight(frame))
        
        button.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if xOrigin < 40 {
            println("***ATTENTION!*** Button at index \(index) is going to leave less than 40 points of space! That's going to be hard to close.")
        }
        
        return button
    }
    
    func buttonClicked(sender: UIButton) {
        if let index = find(buttons, sender) {
            delegate?.swipeableCell(self, didSelectButtonAtIndex: index)
        }
    }
    
    //MARK: - Measurement convenience methods
    
    private func halfOfFirstButtonWidth() -> CGFloat {
        let firstButton = buttons[0]
        return CGRectGetWidth(firstButton.frame) / 2
    }
    
    private func halfOfLastButtonXPosition() -> CGFloat {
        let lastButton = buttons.last
        let halfOfLastButton = CGRectGetWidth(lastButton!.frame) / 2
        return buttonTotalWidth() - halfOfLastButton
    }
    
    private func buttonTotalWidth() -> CGFloat {
        var buttonWidth: CGFloat = 0
        for button in buttons {
            buttonWidth += CGRectGetWidth(button.frame)
        }
        return buttonWidth
    }
    
    //MARK: - Constraint Animation
    //MARK: Public
    func openCell(#animated: Bool) {
        configureButtonsIfNeeded()
        setConstraintsToShowAllButtons(animated, notifyDelegateDidOpen: false)
    }
    
    func closeCell(#animated: Bool) {
        configureButtonsIfNeeded()
        resetConstraintContstantsToZero(animated, notifyDelegateDidClose: false)
    }
    
    //MARK: Private
    private func setConstraintsToShowAllButtons(animated: Bool, notifyDelegateDidOpen notifyDelegate: Bool) {
        opened = true
        if notifyDelegate {
            delegate?.swipeableCellDidOpen(self)
        }
        let totalWidth = buttonTotalWidth()
        if startingRightLayoutConstraintConstant == totalWidth && contentViewRightConstraint?.constant == totalWidth {
            return
        }
        
        contentViewLeftConstraint?.constant = -totalWidth
        contentViewRightConstraint?.constant = totalWidth
        updateConstraintsIfNeeded(animated, completion: { (finished) -> () in
            if let constant = self.contentViewRightConstraint?.constant {
                self.startingRightLayoutConstraintConstant = constant
            }
        })
    }
    
    private func resetConstraintContstantsToZero(animated: Bool, notifyDelegateDidClose notifyDelegate: Bool) {
        opened = false
        if notifyDelegate {
            delegate?.swipeableCellDidClose(self)
        }
        if startingRightLayoutConstraintConstant == 0 && contentViewRightConstraint?.constant == 0 {
            return
        }
        contentViewRightConstraint?.constant = 0
        contentViewLeftConstraint?.constant = 0
        updateConstraintsIfNeeded(animated) { (finished) in
            if let constant = self.contentViewRightConstraint?.constant {
                self.startingRightLayoutConstraintConstant = constant
            }
        }
    }
    
    private func updateConstraintsIfNeeded(animated: Bool, completion: ((finished: Bool) -> ())) {
        var duration = 0.0
        if animated {
            duration = 0.4
        }
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            }, completion: completion)
    }
    
    //MARK: - UIGestureRecognizerDelegate
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocityInView(customContentView)
            if velocity.x > 0 {
                return true
            } else if fabsf(Float(velocity.x)) > fabsf(Float(velocity.y)) {
                return false
            }
        }
        return true
    }
    
    //MARK: - Gesture Recognizer target
    
    func panThisCell(recognizer: UIPanGestureRecognizer) {
        let currentPoint = recognizer.translationInView(customContentView)
        let movingHorizontally = fabsf(Float(panStartPoint.y)) < fabsf(Float(panStartPoint.x))
        switch recognizer.state {
        case UIGestureRecognizerState.Began:
            configureButtonsIfNeeded()
            panStartPoint = currentPoint
            if let constant = self.contentViewRightConstraint?.constant {
                self.startingRightLayoutConstraintConstant = constant
            }
        case UIGestureRecognizerState.Changed:
            if movingHorizontally {
                // Started by moving horizontally
                let deltaX = currentPoint.x - panStartPoint.x
                var panningLeft = false
                if currentPoint.x < panStartPoint.x {
                    panningLeft = true
                }
                
                let adjustment = startingRightLayoutConstraintConstant - deltaX
                if !panningLeft {
                    let constant = max(adjustment, 0)
                    if constant == 0 {
                        resetConstraintContstantsToZero(true, notifyDelegateDidClose: false)
                    } else {
                        contentViewRightConstraint?.constant = constant
                    }
                } else {
                    let constant = min(adjustment, buttonTotalWidth())
                    if constant == buttonTotalWidth() {
                        setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: false)
                    } else {
                        contentViewRightConstraint?.constant = constant
                    }
                }
                if let rightConstraint = contentViewRightConstraint {
                    contentViewLeftConstraint?.constant = -rightConstraint.constant
                }
            }
        case UIGestureRecognizerState.Ended:
            if movingHorizontally {
                if startingRightLayoutConstraintConstant == 0 {
                    // opening
                    let halfWidth = halfOfFirstButtonWidth()
                    if halfWidth != 0 && contentViewRightConstraint?.constant >= halfWidth {
                        // Open all the way
                        setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
                    } else {
                        // Re-close
                        resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
                    }
                } else {
                    // closing
                    if contentViewRightConstraint?.constant >= halfOfLastButtonXPosition() {
                        // Re-open all the way
                        setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
                    } else {
                        // Close
                        resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
                    }
                }
            }
        case UIGestureRecognizerState.Cancelled:
            if movingHorizontally {
                // Start by moving horizontally
                if startingRightLayoutConstraintConstant == 0 {
                    // We were closed - reset everything to 0
                    resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
                } else {
                    // We were open - reset to the open state
                    setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
                }
            }
        default: ()
        }
    }
}
