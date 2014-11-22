//
//  LocationTableViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 6/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class GPSLocationTableViewCell: UITableViewCell {
    lazy var didPressAddButtonBlock: () -> () = {}
    
    @IBAction func addButtonClicked(sender: UIButton) {
        if didPressAddButtonBlock != nil {
            didPressAddButtonBlock()
        }
    }
}
