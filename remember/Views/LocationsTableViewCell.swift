//
//  LocationsTableViewCell.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class LocationsTableViewCell: SwipeableTableViewCell {

    let radioButton = RadioButton()
    let locationNameLabel = UILabel()

    override func commonInit() {
        super.commonInit()
        dataSource = self
        makeLayout()
    }

    private func makeLayout() {
        radioButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        locationNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        customContentView.addSubview(radioButton)
        customContentView.addSubview(locationNameLabel)

        radioButton.backgroundColor = UIColor.clearColor()

        let viewsDict = ["radioButton": radioButton, "locationNameLabel": locationNameLabel]
        let metricsDict = ["radioButtonLeftMargin": 20, "radioButtonWidth": 24, "radioButtonRightMargin": 16, "locationNameLabelRightMargin": 16]

        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-radioButtonLeftMargin-[radioButton(radioButtonWidth)]-radioButtonRightMargin-[locationNameLabel]-locationNameLabelRightMargin-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: metricsDict, views: viewsDict)

        let radioButtonHeightConstraint = NSLayoutConstraint(item: radioButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: radioButton, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)

        let radioButtonCenterYConstraint = NSLayoutConstraint(item: radioButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: customContentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)

        customContentView.addConstraints(horizontalConstraints)
        customContentView.addConstraints([radioButtonHeightConstraint, radioButtonCenterYConstraint])
    }

    func checkRadioButton() {
        radioButton.setChecked(true)
    }

    func uncheckedRadioButton() {
        radioButton.setChecked(false)
    }

    func isChecked() -> Bool {
        return radioButton._checked
    }
}

extension LocationsTableViewCell: SwipeableTableViewCellDataSource {
    func numberOfButtonsInSwipeableCell(cell: SwipeableTableViewCell) -> Int {
        return 2
    }

    func swipeableCell(cell: SwipeableTableViewCell, backgroundImageForButtonAtIndex index: Int) -> UIImage? {
        if index == 0 {
            return UIImage(named: "trash")
        } else {
            return UIImage(named: "edit")
        }
    }
}
