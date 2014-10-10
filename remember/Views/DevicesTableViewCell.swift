//
//  DevicesTableViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable class DevicesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    lazy var didPressAddButtonBlock: () -> () = {}
    
    @IBAction func addButtonPressed(sender: UIButton) {
        if self.didPressAddButtonBlock != nil {
            self.didPressAddButtonBlock()
        }
    }
}