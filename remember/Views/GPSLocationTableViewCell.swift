//
//  LocationTableViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 6/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class GPSLocationTableViewCell: AddableTableViewCell {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    
    @IBAction func addButtonPressed(sender: UIButton) {
        performAddAction(sender)
    }
}
