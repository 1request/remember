//
//  MessagesTableViewCell.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class MessagesTableViewCell: SwipeableTableViewCell {
    
    let UNREAD = NSLocalizedString("UNREAD", comment: "unread button label text")
    
    let unreadSpotIcon = UnreadSpotView()
    let playButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    let messageLabel = UILabel()

    enum PlayerStatus {
        case Normal, Playing
    }
    
    var active: Bool = true {
        didSet {
            var imagename = ""
            let name = active ? "active" : "inactive"
            if status == PlayerStatus.Normal {
                imagename = "play"
            } else {
                imagename = "pause"
            }
            playButton.setBackgroundImage(UIImage(named: imagename + "-" + name), forState: .Normal)
        }
    }
    
    var status: PlayerStatus = PlayerStatus.Normal

    override func commonInit() {
        super.commonInit()
        dataSource = self
        makeLayout()
    }

    private func makeLayout() {
        unreadSpotIcon.setTranslatesAutoresizingMaskIntoConstraints(false)
        playButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        playButton.setBackgroundImage(UIImage(named: "play-active"), forState: UIControlState.Normal)
        messageLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        customContentView.addSubview(unreadSpotIcon)
        customContentView.addSubview(playButton)
        customContentView.addSubview(messageLabel)

        let viewsDict = ["unreadSpotIcon": unreadSpotIcon, "playButton": playButton, "messageLabel": messageLabel]

        let metricsDict = ["unreadSpotIconLeftMargin": 26, "unreadSpotIconRightMargin": 22, "unreadSpotIconWidth": 12, "buttonWidth": 20, "buttonRightMargin": 20]

        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-unreadSpotIconLeftMargin-[unreadSpotIcon(unreadSpotIconWidth)]-unreadSpotIconRightMargin-[messageLabel]-[playButton(buttonWidth)]-buttonRightMargin-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: metricsDict, views: viewsDict)

        let unreadSpotViewHeightConstraint = NSLayoutConstraint(item: unreadSpotIcon, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: unreadSpotIcon, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)

        let unreadSpotViewCenterYConstraint = NSLayoutConstraint(item: unreadSpotIcon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: customContentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)

        let playButtonRatioConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: playButton, attribute: NSLayoutAttribute.Width, multiplier: (32.0/27.0), constant: 0.0)

        unreadSpotIcon.backgroundColor = UIColor.clearColor()

        customContentView.addConstraints(horizontalConstraints)
        customContentView.addConstraints([unreadSpotViewHeightConstraint, unreadSpotViewCenterYConstraint, playButtonRatioConstraint])
    }

    func markAsRead() {
        unreadSpotIcon.hidden = true
        messageLabel.textColor = UIColor.appGrayTextColor()
    }

    func markAsUnread() {
        unreadSpotIcon.hidden = false
        messageLabel.textColor = UIColor.appBlackTextColor()
    }

    func startPlaying() {
        markAsRead()
        setPlayerStatus(.Playing)
    }
    
    func finishPlaying() {
        setPlayerStatus(.Normal)
    }
    
    func setPlayerStatus(status: PlayerStatus) {
        self.status = status
        switch status {
        case PlayerStatus.Playing:
            playButton.setBackgroundImage(UIImage(named: "pause-active"), forState: .Normal)
            
        default:
            playButton.setBackgroundImage(UIImage(named: "play-active"), forState: .Normal)
        }
    }
}

extension MessagesTableViewCell: SwipeableTableViewCellDataSource {
    func numberOfButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int {
        if unreadSpotIcon.hidden {
            return 2
        } else {
            return 1
        }
    }

    func swipeableCell(cell: SwipeableTableViewCell, backgroundImageForButtonAtIndex index: Int) -> UIImage? {
        if index == 0 {
            return UIImage(named: "trash")
        } else {
            return nil
        }
    }
    
    func swipeableCell(cell: SwipeableTableViewCell, titleForButtonAtIndex index: Int) -> String? {
        if index == 1 && unreadSpotIcon.hidden {
            return UNREAD
        } else {
            return nil
        }
    }
}
