//
//  MessagesTableViewCell.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class MessagesTableViewCell: SwipeableTableViewCell {

    let unreadSpotIcon = UnreadSpotView()
    let playButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    let messageLabel = UILabel()
    var playing = false

    enum PlayerStatus {
        case Normal, Playing
    }

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

        setPlayerStatus(PlayerStatus.Playing)
    }
    
    func finishPlaying() {
        setPlayerStatus(PlayerStatus.Normal)
    }

    func setPlayerStatus(status: PlayerStatus) {
        switch status {
        case PlayerStatus.Playing:
            playing = true
            playButton.setBackgroundImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        default:
            playing = false
            playButton.setBackgroundImage(UIImage(named: "play-active"), forState: UIControlState.Normal)
        }
    }
}

extension MessagesTableViewCell: SwipeableTableViewCellDataSource {
    func numberOfButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int {
        return 1
    }

    func swipeableCell(cell: SwipeableTableViewCell, backgroundImageForButtonAtIndex index: Int) -> UIImage? {
        return UIImage(named: "trash")
    }
}
