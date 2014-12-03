//
//  GroupsTableViewCell.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class GroupsTableViewCell: SwipeableTableViewCell {

    let radioButton = RadioButton()
    let groupNameLabel = UILabel()

    override func commonInit() {
        super.commonInit()
        dataSource = self
        makeLayout()
    }

    private func makeLayout() {
        radioButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        groupNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        groupNameLabel.textColor = UIColor.appGreenTextColor()

        customContentView.addSubview(radioButton)
        customContentView.addSubview(groupNameLabel)

        radioButton.backgroundColor = UIColor.clearColor()

        let viewsDict = ["radioButton": radioButton, "groupNameLabel": groupNameLabel]
        let metricsDict = ["radioButtonLeftMargin": 20, "radioButtonWidth": 24, "radioButtonRightMargin": 16, "groupNameLabelRightMargin": 16]

        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-radioButtonLeftMargin-[radioButton(radioButtonWidth)]-radioButtonRightMargin-[groupNameLabel]-groupNameLabelRightMargin-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: metricsDict, views: viewsDict)

        let radioButtonHeightConstraint = NSLayoutConstraint(item: radioButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: radioButton, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)

        let radioButtonCenterYConstraint = NSLayoutConstraint(item: radioButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: customContentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)

        customContentView.addConstraints(horizontalConstraints)
        customContentView.addConstraints([radioButtonHeightConstraint, radioButtonCenterYConstraint])
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
}

extension GroupsTableViewCell: SwipeableTableViewCellDataSource {
    func numberOfRightButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int {
        return 2
    }
    
    func numberOfLeftButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int {
        return 0
    }
    
    func swipeableCell(cell: SwipeableTableViewCell, backgroundImageForButtonAtIndex index: Int, atDirection: Int) -> UIImage? {
        if atDirection == SwipeableTableViewCell.Direction.right.rawValue {
            if index == 0 {
                return UIImage(named: "trash")
            } else {
                return UIImage(named: "edit")
            }
        } else {
            return nil
        }
    }
}

