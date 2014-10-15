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
    @IBOutlet weak var deleteButton: UIButton!
    
    var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    var delegate: MessagesTableViewCellDelegate!
    var panStartPoint: CGPoint!
    var startingRightLayoutConstraintConstant: CGFloat!
    @IBOutlet weak var contentViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewRightConstraint: NSLayoutConstraint!
    
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
    
    @IBAction func buttonClicked(sender: UIButton) {
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
        case UIGestureRecognizerState.Changed:

            let currentPoint = recognizer.translationInView(topView)
            let deltaX = currentPoint.x - panStartPoint.x

            var panningLeft = false
            if currentPoint.x < panStartPoint.x {
                panningLeft = true
            }
            if startingRightLayoutConstraintConstant == 0 {
                // the cell was closed and is now opening
                if !panningLeft {
                    let constant = max(-deltaX, 0)
                    if (constant == 0) {
                        resetConstraintConstantsToZero(true, notifyDelegateDidClose: false)
                    } else {
                        contentViewRightConstraint.constant = constant
                    }
                } else {
                    let constant = min(-deltaX, buttonTotalWidth())
                    if constant == buttonTotalWidth() {
                        setConstraintConstantsToShowAllButtons(true, notifyDelegateDidOpen: false)
                    } else {
                        delegate.cellWillOpen(self)
                        contentViewRightConstraint.constant = constant
                    }
                }
            } else {
                // The cell was at least partially open
                let adjustment = startingRightLayoutConstraintConstant - deltaX
                
                if !panningLeft {
                    let constant = max(adjustment, 0)
                    if constant == 0 {
                        resetConstraintConstantsToZero(true, notifyDelegateDidClose: false)
                    } else {
                        contentViewRightConstraint.constant = constant
                    }
                } else {
                    let constant = min(adjustment, buttonTotalWidth())
                    if constant == buttonTotalWidth() {
                        setConstraintConstantsToShowAllButtons(true, notifyDelegateDidOpen: false)
                    } else {
                        contentViewRightConstraint.constant = constant
                    }
                }
            }
            
            contentViewLeftConstraint.constant = -contentViewRightConstraint.constant
        case UIGestureRecognizerState.Ended:
            let halfOfButton = CGRectGetWidth(self.deleteButton.frame) / 2
            if contentViewRightConstraint.constant >= halfOfButton {
                setConstraintConstantsToShowAllButtons(true, notifyDelegateDidOpen: true)
            } else {
                resetConstraintConstantsToZero(true, notifyDelegateDidClose: true)
            }
        case UIGestureRecognizerState.Cancelled:
            if startingRightLayoutConstraintConstant == 0 {
                resetConstraintConstantsToZero(true, notifyDelegateDidClose: true)
            } else {
                setConstraintConstantsToShowAllButtons(true, notifyDelegateDidOpen: true)
            }
        default: ()
        }
    }
    
    func resetConstraintConstantsToZero(animated: Bool, notifyDelegateDidClose: Bool) {
        if notifyDelegateDidClose {
            delegate.cellDidClose(self)
        }

        if startingRightLayoutConstraintConstant == 0 && contentViewRightConstraint == 0 {
            return
        }
        
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

        if startingRightLayoutConstraintConstant == buttonTotalWidth() && contentViewRightConstraint.constant == buttonTotalWidth() {
            return
        }
        
        contentViewLeftConstraint.constant = -self.buttonTotalWidth() - kBounceValue
        contentViewRightConstraint.constant = self.buttonTotalWidth() + kBounceValue
        
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
    
    func closeCell(#animated: Bool) {
        resetConstraintConstantsToZero(animated, notifyDelegateDidClose: false)
    }
    
}
