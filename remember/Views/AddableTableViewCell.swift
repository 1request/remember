//
//  AddableTableViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 27/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class AddableTableViewCell: UITableViewCell {
    
    lazy var didPressAddButtonBlock: () -> () = {}
    
    func performAddAction(sender: UIButton) {
        if didPressAddButtonBlock != nil {
            didPressAddButtonBlock()
        }
    }
}
