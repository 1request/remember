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
    let profileImageView = UIImageView()
    var profileImage: UIImage? {
        didSet {
            makeLayout()
        }
    }

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

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage = nil
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
        profileImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        customContentView.removeConstraints(customContentView.constraints())
        customContentView.addSubview(unreadSpotIcon)
        customContentView.addSubview(playButton)
        customContentView.addSubview(messageLabel)
        
        let viewsDict = ["unreadSpotIcon": unreadSpotIcon, "playButton": playButton, "messageLabel": messageLabel, "profileImageView": profileImageView]
        
        let metricsDict = ["unreadSpotIconLeftMargin": 26, "unreadSpotIconRightMargin": 22, "unreadSpotIconWidth": 12, "buttonWidth": 20, "buttonRightMargin": 20, "profileImageViewLeftMargin": 20, "profileImageViewRightMargin": 16, "profileImageViewWidth": 24]

        let unreadSpotViewCenterYConstraint = NSLayoutConstraint(item: unreadSpotIcon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: customContentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        
        let unreadSpotViewHeightConstraint = NSLayoutConstraint(item: unreadSpotIcon, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: unreadSpotIcon, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)

        let playButtonRatioConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: playButton, attribute: NSLayoutAttribute.Width, multiplier: (32.0/27.0), constant: 0.0)
        
        unreadSpotIcon.backgroundColor = UIColor.clearColor()
        
        customContentView.addConstraints([unreadSpotViewHeightConstraint, unreadSpotViewCenterYConstraint, playButtonRatioConstraint])
        
        var horizontalConstraints = [AnyObject]()
        if let image = profileImage {
            customContentView.addSubview(profileImageView)
            profileImageView.image = image
            profileImageView.contentMode = .ScaleAspectFill
            profileImageView.clipsToBounds = true
            profileImageView.hidden = false

            let profileImageCenterYConstraint = NSLayoutConstraint(item: profileImageView, attribute: .CenterY, relatedBy: .Equal, toItem: customContentView, attribute: .CenterY, multiplier: 1, constant: 0)
            let profileImageHeightConstraint = NSLayoutConstraint(item: profileImageView, attribute: .Height, relatedBy: .Equal, toItem: profileImageView, attribute: .Width, multiplier: 1, constant: 0)
            customContentView.addConstraints([profileImageCenterYConstraint, profileImageHeightConstraint])
            
            horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-profileImageViewLeftMargin-[profileImageView(profileImageViewWidth)]-profileImageViewRightMargin-[messageLabel]-[playButton(buttonWidth)]-buttonRightMargin-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: metricsDict, views: viewsDict)
        } else {
            profileImageView.hidden = true
            horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-unreadSpotIconLeftMargin-[unreadSpotIcon(unreadSpotIconWidth)]-unreadSpotIconRightMargin-[messageLabel]-[playButton(buttonWidth)]-buttonRightMargin-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: metricsDict, views: viewsDict)
        }
        
        customContentView.addConstraints(horizontalConstraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2.0
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
    func numberOfRightButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int {
        if unreadSpotIcon.hidden {
            return 1
        } else {
            return 1
        }
    }
    
    func numberOfLeftButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int {
        if unreadSpotIcon.hidden {
            return 1
        } else {
            return 0
        }
    }

    func swipeableCell(cell: SwipeableTableViewCell, backgroundImageForButtonAtIndex index: Int, atDirection: Int) -> UIImage? {
        if atDirection == SwipeableTableViewCell.Direction.right.rawValue && index == 0 {
            return UIImage(named: "trash")
        } else {
            return nil
        }
    }
    
    func swipeableCell(cell: SwipeableTableViewCell, titleForButtonAtIndex index: Int, atDirection: Int) -> String? {
        if index == 0 && unreadSpotIcon.hidden && atDirection == SwipeableTableViewCell.Direction.left.rawValue {
            return UNREAD
        } else {
            return nil
        }
    }
    
    func swipeableCell(cell: SwipeableTableViewCell, backgroundColorForButtonAtIndex index: Int, atDirection: Int) -> UIColor? {
        if index == 0 && unreadSpotIcon.hidden && atDirection == SwipeableTableViewCell.Direction.left.rawValue  {
            return UIColor.appBlueColor()
        } else {
            return nil
        }
    }
}
