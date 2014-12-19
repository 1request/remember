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
    func numberOfRightButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int
    func numberOfLeftButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int
    
    optional func swipeableCell(cell: SwipeableTableViewCell, buttonForIndex index: Int, atDirection direction: Int) -> UIButton?

    optional func swipeableCell(cell: SwipeableTableViewCell, titleForButtonAtIndex index: Int, atDirection: Int) -> String?
    optional func swipeableCell(cell: SwipeableTableViewCell, backgroundColorForButtonAtIndex index: Int, atDirection: Int) -> UIColor?
    optional func swipeableCell(cell: SwipeableTableViewCell, tintColorForButtonAtIndex index: Int, atDirection: Int) -> UIColor?
    optional func swipeableCell(cell: SwipeableTableViewCell, backgroundImageForButtonAtIndex index: Int, atDirection: Int) -> UIImage?
    optional func swipeableCell(cell: SwipeableTableViewCell, fontForButtonAtIndex index: Int, atDirection: Int) -> UIFont?
}

//MARK: - SwipeableTableViewCellDelegate

@objc protocol SwipeableTableViewCellDelegate {
    func swipeableCell(cell: SwipeableTableViewCell, didSelectButtonAtIndex index: Int, direction: Int)
    func swipeableCellDidOpen(cell: SwipeableTableViewCell, direction: Int)
    func swipeableCellDidClose(cell: SwipeableTableViewCell, direction: Int)
}

//MARK: - SwipeableTableViewCell Class

class SwipeableTableViewCell: UITableViewCell, UIGestureRecognizerDelegate {
    var opened = false
    var openedDirection: Direction? = nil
    
    var customContentView = UIView()
    weak var delegate: SwipeableTableViewCellDelegate?
    weak var dataSource: SwipeableTableViewCellDataSource?
    
    var rightButtons: [UIButton] = []
    var leftButtons: [UIButton] = []
    
    private var panStartPoint = CGPointZero
    private var startingRightLayoutConstraintConstant: CGFloat = 0
    private var contentViewRightConstraint: NSLayoutConstraint?
    private var contentViewLeftConstraint: NSLayoutConstraint?
    
    enum Direction: Int {
        case left
        case right
    }
    
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
        
        removeAllButtonsFromViewAtDirection(Direction.right)
        removeAllButtonsFromViewAtDirection(Direction.left)
    }
    
    private func removeAllButtonsFromViewAtDirection(direction: Direction) {
        if direction == Direction.left {
            for button in leftButtons {
                button.removeFromSuperview()
            }
        } else {
            for button in leftButtons {
                button.removeFromSuperview()
            }
        }
        rightButtons.removeAll(keepCapacity: false)
        leftButtons.removeAll(keepCapacity: false)
    }
    
    //MARK: - Button Config
    
    
    private func addButtons(numberOfButtons: Int, AtDirection direction: Direction) {
        var previousMinX:CGFloat = 0.0
        if direction == Direction.right {
            previousMinX = CGRectGetWidth(frame)
        }
        for i in 0..<numberOfButtons {
            let button = buttonForIndex(i, previousButtonMinX: previousMinX, direction: direction)
            if direction == Direction.right {
                previousMinX -= CGRectGetWidth(button.frame)
                rightButtons.append(button)
            } else {
                previousMinX += CGRectGetWidth(button.frame)
                leftButtons.append(button)
            }
            
            contentView.addSubview(button)
        }
        contentView.bringSubviewToFront(customContentView)
    }
    
    private func configureButtonsAtDirection(direction: Direction) {
        if direction == Direction.right {
            if let numberOfButtons = dataSource?.numberOfRightButtonsInSwipeableCell(self) {
                addButtons(numberOfButtons, AtDirection: Direction.right)
            }
        } else {
            if let numberOfButtons = dataSource?.numberOfLeftButtonsInSwipeableCell(self) {
                addButtons(numberOfButtons, AtDirection: Direction.left)
            }
        }
    }
    
    private func buttonsAtDirection(direction: Direction) -> [UIButton] {
        if direction == Direction.left {
            return leftButtons
        } else {
            return rightButtons
        }
    }
    
    private func configureButtonsIfNeededAtDirection(direction: Direction) {
        if direction == Direction.right {
            removeAllButtonsFromViewAtDirection(Direction.left)
        } else {
            removeAllButtonsFromViewAtDirection(Direction.right)
        }
        let buttons = rightButtons + leftButtons
        if buttons.count == 0 {
            configureButtonsAtDirection(direction)
        }
    }
    
    private func buttonFromDataSourceAtIndex(index: Int, atDirection direction: Direction) -> UIButton {
        var button = UIButton()
        
        if let customButton = dataSource?.swipeableCell?(self, buttonForIndex: index, atDirection: direction.rawValue) {
            button = customButton
        } else {
            if let title = dataSource?.swipeableCell?(self, titleForButtonAtIndex: index, atDirection: direction.rawValue) {
                let spacing:CGFloat = 5
                button.setTitle(title, forState: UIControlState.Normal)
                button.contentEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
            } else {
                button.setTitle("", forState: UIControlState.Normal)
            }
            
            if let image = dataSource?.swipeableCell?(self, backgroundImageForButtonAtIndex: index, atDirection: direction.rawValue) {
                button.setBackgroundImage(image, forState: UIControlState.Normal)
                button.frame.size.width = image.size.width / image.size.height * frame.height
            }
            
            if let tintColor = dataSource?.swipeableCell?(self, tintColorForButtonAtIndex: index, atDirection: direction.rawValue) {
                button.tintColor = tintColor
            } else {
                button.tintColor = UIColor.whiteColor()
            }
            
            if let font = dataSource?.swipeableCell?(self, fontForButtonAtIndex: index, atDirection: direction.rawValue) {
                button.titleLabel?.font = font
            }
            
            if let backgroundColor = dataSource?.swipeableCell?(self, backgroundColorForButtonAtIndex: index, atDirection: direction.rawValue) {
                button.backgroundColor = backgroundColor
            } else {
                if dataSource?.swipeableCell?(self, backgroundImageForButtonAtIndex: index, atDirection: direction.rawValue) == nil {
                    if index == 0 {
                        button.backgroundColor = UIColor.redColor()
                    } else {
                        button.backgroundColor = UIColor.lightGrayColor()
                    }
                }
            }
            
            if (dataSource?.swipeableCell?(self, backgroundImageForButtonAtIndex: index, atDirection: direction.rawValue) == nil) {
                button.sizeToFit()
            }
            
            let appleRecommendedMinimumTouchPointWidth = 44.0 as CGFloat
            
            if button.frame.size.width < appleRecommendedMinimumTouchPointWidth {
                var frame = button.frame
                frame.size.width = appleRecommendedMinimumTouchPointWidth
                button.frame = frame
            }
        }
        return button
    }
    
    private func buttonForIndex(index: Int, previousButtonMinX previousMinX: CGFloat, direction: Direction) -> UIButton {
        let button = buttonFromDataSourceAtIndex(index, atDirection: direction)
        var xOrigin: CGFloat = 0
        
        if direction == Direction.right {
            xOrigin = previousMinX - CGRectGetWidth(button.frame)
            
        } else {
            
        }
        
        button.frame = CGRectMake(xOrigin, 0, CGRectGetWidth(button.frame), CGRectGetHeight(frame))
        
        button.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if direction == Direction.right {
            if xOrigin < 40 {
                println("***ATTENTION!*** Right button at index \(index) is going to leave less than 40 points of space! That's going to be hard to close.")
            }
        } else {
            let distance = CGRectGetWidth(frame) - xOrigin
            if  distance < 40 {
                println("***ATTENTION!*** Left button at index \(index) is going to leave less than 40 points of space! That's going to be hard to close.")
            }
        }
        
        return button
    }
    
    func buttonClicked(sender: UIButton) {
        if let index = find(rightButtons, sender) {
            delegate?.swipeableCell(self, didSelectButtonAtIndex: index, direction: Direction.right.rawValue)
            return
        }
        if let index = find(leftButtons, sender) {
            delegate?.swipeableCell(self, didSelectButtonAtIndex: index, direction: Direction.left.rawValue)
            return
        }
    }
    
    //MARK: - Measurement convenience methods
    
    private func halfOfFirstButtonWidthAtDirection(direction: Direction) -> CGFloat {
        var firstButton = UIButton()
        if direction == Direction.right {
            firstButton = rightButtons[0]
        } else {
            firstButton = leftButtons[0]
        }
        return CGRectGetWidth(firstButton.frame) / 2
    }
    
    private func halfOfLastButtonXPositionAtDirection(direction: Direction) -> CGFloat {
        var lastButton: UIButton?
        if direction == Direction.right {
            lastButton = rightButtons.last
        } else {
            lastButton = leftButtons.last
        }
        
        let halfOfLastButton = CGRectGetWidth(lastButton!.frame) / 2
        return buttonTotalWidthAtDirection(direction) - halfOfLastButton
    }
    
    private func buttonTotalWidthAtDirection(direction: Direction) -> CGFloat {
        var buttonWidth: CGFloat = 0
        if direction == Direction.right {
            for button in rightButtons {
                buttonWidth += CGRectGetWidth(button.frame)
            }
        } else {
            for button in leftButtons {
                buttonWidth += CGRectGetWidth(button.frame)
            }
        }
        return buttonWidth
    }
    
    //MARK: - Constraint Animation
    //MARK: Public
    func openCell(#animated: Bool, direction: Direction) {
        configureButtonsIfNeededAtDirection(direction)
        openedDirection = direction
        setConstraintsToShowAllButtons(animated, notifyDelegateDidOpen: false)
    }
    
    func closeCell(#animated: Bool, direction: Direction) {
        configureButtonsIfNeededAtDirection(direction)
        openedDirection = direction
        resetConstraintContstantsToZero(animated, notifyDelegateDidClose: false)
    }
    
    //MARK: Private
    private func setConstraintsToShowAllButtons(animated: Bool, notifyDelegateDidOpen notifyDelegate: Bool) {
        opened = true
        if notifyDelegate {
            delegate?.swipeableCellDidOpen(self, direction: openedDirection!.rawValue)
        }
        if let direction = openedDirection {
            let totalWidth = buttonTotalWidthAtDirection(direction)
            
            if abs(startingRightLayoutConstraintConstant) == totalWidth && abs(contentViewRightConstraint!.constant) == totalWidth {
                return
            }
            
            if direction == Direction.right {
                contentViewLeftConstraint?.constant = -totalWidth
                contentViewRightConstraint?.constant = totalWidth
            } else {
                contentViewLeftConstraint?.constant = totalWidth
                contentViewRightConstraint?.constant = -totalWidth
            }
            
            updateConstraintsIfNeeded(animated, completion: { (finished) -> () in
                if let constant = self.contentViewRightConstraint?.constant {
                    self.startingRightLayoutConstraintConstant = constant
                }
            })
        }
    }
    
    private func resetConstraintContstantsToZero(animated: Bool, notifyDelegateDidClose notifyDelegate: Bool) {
        opened = false
        if notifyDelegate {
            delegate?.swipeableCellDidClose(self, direction: openedDirection!.rawValue)
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
            panStartPoint = currentPoint
            
            if let constant = contentViewRightConstraint?.constant {
                startingRightLayoutConstraintConstant = constant
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
                    if startingRightLayoutConstraintConstant == 0 {
                        // start opening left direction, show left buttons
                        configureButtonsIfNeededAtDirection(Direction.left)
                        openedDirection = Direction.left
                    }
                    if openedDirection! == Direction.left {
                        let constant = min(-adjustment, buttonTotalWidthAtDirection(Direction.left))
                        if constant == buttonTotalWidthAtDirection(Direction.left) {
                            setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: false)
                        } else {
                            contentViewRightConstraint?.constant = -constant
                        }
                    } else {
                        let constant = max(adjustment, 0)
                        
                        if constant == 0 {
                            resetConstraintContstantsToZero(true, notifyDelegateDidClose: false)
                        } else {
                            contentViewRightConstraint?.constant = constant
                        }
                    }
                } else {
                    if startingRightLayoutConstraintConstant == 0 {
                        // start opening right direction, show right buttons
                        configureButtonsIfNeededAtDirection(Direction.right)
                        openedDirection = Direction.right
                    }
                    if openedDirection! == Direction.right {
                        let constant = min(adjustment, buttonTotalWidthAtDirection(Direction.right))
                        if constant == buttonTotalWidthAtDirection(Direction.right) {
                            setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: false)
                        } else {
                            contentViewRightConstraint?.constant = constant
                        }
                    } else {
                        let constant = max(-adjustment, 0)
                        if constant == 0 {
                            resetConstraintContstantsToZero(true, notifyDelegateDidClose: false)
                        } else {
                            contentViewRightConstraint?.constant = -constant
                        }
                    }
                }
                if let rightConstraint = contentViewRightConstraint {
                    contentViewLeftConstraint?.constant = -rightConstraint.constant
                }
            }
        case UIGestureRecognizerState.Ended:
            if movingHorizontally {
                if let direction = openedDirection {
                    if buttonsAtDirection(direction).count > 0 {
                        if startingRightLayoutConstraintConstant == 0 {
                            // opening
                            let halfWidth = halfOfFirstButtonWidthAtDirection(direction)
                            if halfWidth != 0 && abs(contentViewRightConstraint!.constant) >= halfWidth {
                                // Open all the way
                                setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
                            } else {
                                // Re-close
                                resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
                            }
                        } else {
                            // closing
                            if abs(contentViewRightConstraint!.constant) >= halfOfLastButtonXPositionAtDirection(openedDirection!) {
                                // Re-open all the way
                                println("re-open cell")
                                setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
                            } else {
                                // Close
                                println("close cell")
                                resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
                            }
                        }
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
