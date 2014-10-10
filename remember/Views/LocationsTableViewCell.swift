//
//  LocationsTableViewCell.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class LocationsTableViewCell: UITableViewCell {

    @IBOutlet weak var radioButton: RadioButton!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
