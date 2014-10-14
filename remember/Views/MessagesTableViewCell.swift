//
//  MessagesTableViewCell.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

protocol MessagesTableViewCellDelegate {
    func deleteButtonClicked(cell: UITableViewCell)
    func cellWillOpen(cell: UITableViewCell)
    func cellDidOpen(cell: UITableViewCell)
    func cellDidClose(cell: UITableViewCell)
}

class MessagesTableViewCell: UITableViewCell, UIGestureRecognizerDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var unreadSpotIcon: UnreadSpotView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var pauseIcon: UIImageView!
    @IBOutlet weak var deleteButton: UIImageView!
    
    var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    var delegate: MessagesTableViewCellDelegate!
    var panStartPoint: CGPoint!
    var startingRightLayoutConstraintConstant: CGFloat!
    var contentViewLeftConstraint: NSLayoutConstraint!
    var contentViewRightConstraint: NSLayoutConstraint!
    var topViewLeftConstraint: NSLayoutConstraint!
    var topViewRightConstraint: NSLayoutConstraint!
    
    let kBounceValue: CGFloat = 20.0
    
    enum PlayerStatus {
        case Normal, Playing
    }

    var playing: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()	

        // Initialization code
        panRecognizer.addTarget(self, action: "panThisCell:")
        panRecognizer.delegate = self
        topView.addGestureRecognizer(panRecognizer)
        
        contentViewLeftConstraint = NSLayoutConstraint(
            item: topView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal,
            toItem: contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0)
        contentViewRightConstraint = NSLayoutConstraint(
            item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal,
            toItem: topView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0)
        contentView.addConstraints([contentViewLeftConstraint, contentViewRightConstraint])
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func markAsRead() {
        unreadSpotIcon.hidden = true
    }
    
    func markAsUnread() {
        unreadSpotIcon.hidden = false
    }
    
    func startPlaying() {
        markAsRead()
        
        setPlayerStatus(PlayerStatus.Playing)
    }
    
    func finishPlaying() {
        setPlayerStatus(PlayerStatus.Normal)
    }
    
    func setPlayerStatus(status: PlayerStatus) {
        switch status {
        case PlayerStatus.Playing:
            playing = true
            
            playIcon.hidden = true
            pauseIcon.hidden = false
        default:
            // Normal
            playing = false
            
            playIcon.hidden = false
            pauseIcon.hidden = true
        }
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self.deleteButton {
            delegate.deleteButtonClicked(self)
        }
    }

    func buttonTotalWidth() -> CGFloat {
        return CGRectGetWidth(self.frame) - CGRectGetMinX(self.deleteButton.frame)
    }
    
    func panThisCell(recognizer: UIPanGestureRecognizer) {
        switch (recognizer.state) {
        case UIGestureRecognizerState.Began:
            panStartPoint = recognizer.translationInView(topView)
            startingRightLayoutConstraintConstant = contentViewRightConstraint.constant
            delegate.cellWillOpen(self)
            
            break;
        case UIGestureRecognizerState.Changed:
            var currentPoint: CGPoint = recognizer.translationInView(topView)
            var deltaX = currentPoint.x - panStartPoint.x
            
            var panningLeft: Bool = false
            if currentPoint.x < panStartPoint.x {
                panningLeft = true
            }
            
            if startingRightLayoutConstraintConstant == 0 {
                // the cell was closed and is now opening
                if !panningLeft {
                    var constant: CGFloat = max(-deltaX, 0)
                    if (constant == 0) {
                        resetConstraintConstantsToZero(true, notifyDelegateDidClose: false)
                    } else {
                        contentViewRightConstraint.constant = constant
                    }
                } else {
                    var constant: CGFloat = min(-deltaX, buttonTotalWidth())
                    if constant == buttonTotalWidth() {
                        setConstraintConstantsToShowAllButtons(true, notifyDelegateDidOpen: false)
                    } else {
                        contentViewRightConstraint.constant = constant
                    }
                }
            } else {
                // The cell was at least partially open
                var adjustment: CGFloat = startingRightLayoutConstraintConstant - deltaX
                if !panningLeft {
                    var constant: CGFloat = max(adjustment, 0)
                    if constant == 0 {
                        resetConstraintConstantsToZero(true, notifyDelegateDidClose: false)
                    } else {
                        contentViewRightConstraint.constant = constant
                    }
                } else {
                    var constant: CGFloat = min(adjustment, buttonTotalWidth())
                    if constant == buttonTotalWidth() {
                        setConstraintConstantsToShowAllButtons(true, notifyDelegateDidOpen: false)
                    } else {
                        contentViewRightConstraint.constant = constant
                    }
                }
            }
            
            contentViewLeftConstraint.constant = -contentViewRightConstraint.constant
            break;
        case UIGestureRecognizerState.Ended:
            var halfOfButton = CGRectGetWidth(self.deleteButton.frame)
            if contentViewRightConstraint.constant >= halfOfButton {
                setConstraintConstantsToShowAllButtons(true, notifyDelegateDidOpen: true)
            } else {
                resetConstraintConstantsToZero(true, notifyDelegateDidClose: true)
            }
            
            break;
        case UIGestureRecognizerState.Cancelled:
            if startingRightLayoutConstraintConstant == 0 {
                resetConstraintConstantsToZero(true, notifyDelegateDidClose: true)
            } else {
                setConstraintConstantsToShowAllButtons(true, notifyDelegateDidOpen: true)
            }
        default:
            break;
        }
    }
    
    func resetConstraintConstantsToZero(animated: Bool, notifyDelegateDidClose: Bool) {
        if notifyDelegateDidClose {
            delegate.cellDidClose(self)
        }
        
        if startingRightLayoutConstraintConstant == 0 && contentViewRightConstraint == 0 {
            return;
        }
        
        println("resetConstraintConstantsToZero")
        contentViewRightConstraint.constant = -kBounceValue
        contentViewLeftConstraint.constant = kBounceValue
        
        updateConstraintsIfNeeded(animated, completion: { finished in
            self.contentViewLeftConstraint.constant = 0
            self.contentViewRightConstraint.constant = 0
            self.updateConstraintsIfNeeded(animated, completion: { finished in
                self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant
            })
        })
    }
    
    func setConstraintConstantsToShowAllButtons(animated: Bool, notifyDelegateDidOpen: Bool) {
        if notifyDelegateDidOpen {
            delegate.cellDidOpen(self)
        }
        
        if startingRightLayoutConstraintConstant == buttonTotalWidth() && contentViewRightConstraint == buttonTotalWidth() {
            return;
        }
        
        println("setConstraintConstantsToShowAllButtons")
        contentViewRightConstraint.constant = -self.buttonTotalWidth() - kBounceValue
        contentViewLeftConstraint.constant = self.buttonTotalWidth() + kBounceValue
        
        updateConstraintsIfNeeded(animated, completion: { finished in
            self.contentViewLeftConstraint.constant = -self.buttonTotalWidth()
            self.contentViewRightConstraint.constant = self.buttonTotalWidth()
            self.updateConstraintsIfNeeded(animated, completion: { finished in
                self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant
            })
        })
    }
    
   func updateConstraintsIfNeeded(animated: Bool, completion: Bool -> Void) {
        var duration: NSTimeInterval = 0
        if animated {
            duration = 0.1
        }
    
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { self.layoutIfNeeded() }, completion: completion)
    }
    
    func openCell() {
        setConstraintConstantsToShowAllButtons(false, notifyDelegateDidOpen: false)
    }
    
    func closeCell(animated: Bool) {
        resetConstraintConstantsToZero(animated, notifyDelegateDidClose: false)
    }
    
}
