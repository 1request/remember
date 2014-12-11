//
//  NearbyLocationsTableViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 27/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class NearbyLocationsTableViewCell: AddableTableViewCell {
    let SENT = NSLocalizedString("SENT", comment: "application for joining gorup has been sent")
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButtonPressed(sender: UIButton) {
        performAddAction(sender)
    }
    
    func setAsApplied() {
        addButton.setTitle(SENT, forState: .Normal)
        addButton.enabled = false
        addButton.backgroundColor = UIColor.appGrayColor()
    }
}
