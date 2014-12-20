//
//  GroupsTableViewCell.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class GroupsTableViewCell: SwipeableTableViewCell {
    
    lazy var didPressInviteButtonBlock: () -> () = {}
    
    func inviteButtonPressed(sender: UIButton) {
        if didPressInviteButtonBlock != nil {
            didPressInviteButtonBlock()
        }
    }
    
    let radioButton: RadioButton = {
        let button = RadioButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor.clearColor()
        return button
        }()
    
    lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textColor = UIColor.appGreenTextColor()
        return label
        }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "invite"), forState: .Normal)
        button.addTarget(self, action: "inviteButtonPressed", forControlEvents: .TouchUpInside)
        return button
        }()
    
    override func commonInit() {
        super.commonInit()
        dataSource = self
        makeLayout()
    }
    
    private func makeLayout() {
        customContentView.addSubview(radioButton)
        customContentView.addSubview(groupNameLabel)
        customContentView.addSubview(inviteButton)

        let viewsDict = ["radioButton": radioButton, "groupNameLabel": groupNameLabel, "inviteButton": inviteButton]
        let metricsDict = ["radioButtonLeftMargin": 20, "radioButtonWidth": 24, "radioButtonRightMargin": 16, "groupNameLabelRightMargin": 16]

        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-radioButtonLeftMargin-[radioButton(radioButtonWidth)]-radioButtonRightMargin-[groupNameLabel]-groupNameLabelRightMargin-[inviteButton(radioButtonWidth)]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: metricsDict, views: viewsDict)

        let radioButtonHeightConstraint = NSLayoutConstraint(item: radioButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: radioButton, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)

        let radioButtonCenterYConstraint = NSLayoutConstraint(item: radioButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: customContentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        
        let inviteButtonHeightConstraint = NSLayoutConstraint(item: inviteButton, attribute: .Height, relatedBy: .Equal, toItem: inviteButton, attribute: .Width, multiplier: 1, constant: 0)

        customContentView.addConstraints(horizontalConstraints)
        customContentView.addConstraints([radioButtonHeightConstraint, radioButtonCenterYConstraint, inviteButtonHeightConstraint])
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let buttons = leftButtons + rightButtons
        if highlighted {
            customContentView.backgroundColor = UIColor.lightGrayColor()
            if opened {
                for button in buttons {
                    button.hidden = false
                }
            } else {
                for button in buttons {
                    button.hidden = true
                }
            }
        } else {
            customContentView.backgroundColor = UIColor.whiteColor()
            for button in buttons {
                button.hidden = false
            }
        }
    }
    
    func inviteButtonPressed() {
        didPressInviteButtonBlock()
    }
    
    override func prepareForReuse() {
        inviteButton.hidden = false
    }
}

extension GroupsTableViewCell: SwipeableTableViewCellDataSource {
    func numberOfRightButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int {
        return 3
    }
    
    func numberOfLeftButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int {
        return 0
    }
    
    func swipeableCell(cell: SwipeableTableViewCell, backgroundImageForButtonAtIndex index: Int, atDirection: Int) -> UIImage? {
        if atDirection == SwipeableTableViewCell.Direction.right.rawValue {
            if index == 0 {
                return UIImage(named: "trash")
            } else if index == 1 {
                return UIImage(named: "edit")
            } else {
                return UIImage(named: "map")
            }
        } else {
            return nil
        }
    }
}

