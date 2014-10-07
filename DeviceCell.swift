//
//  DeviceCell.swift
//  Remember
//
//  Created by Kaeli Lo on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addDeviceButton: UIButton!
    @IBOutlet weak var addDeviceLabel: UILabel!
    @IBOutlet weak var addedDeviceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func showAddDeviceButton() {
        addDeviceButton.hidden = false
        addDeviceLabel.hidden = false
        addedDeviceLabel.hidden = true
    }
    
    func showAddedDeviceLabel() {
        addDeviceButton.hidden = true
        addDeviceLabel.hidden = true
        addedDeviceLabel.hidden = false
    }
    
}
