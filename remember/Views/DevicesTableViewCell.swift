//
//  DevicesTableViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import UIKit
class DevicesTableViewCell: AddableTableViewCell {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    
    @IBAction func addButtonPressed(sender: UIButton) {
        performAddAction(sender)
    }
}
