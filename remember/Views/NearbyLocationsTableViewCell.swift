//
//  NearbyLocationsTableViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 27/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class NearbyLocationsTableViewCell: AddableTableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButtonPressed(sender: UIButton) {
        performAddAction(sender)
    }

}
