//
//  MembershipsTableViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 24/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

protocol MembershipsTableViewCellDelegate {
    func membershipTableViewCellDidPressApproveButton(cell: MembershipsTableViewCell)
    func membershipTableViewCellDidPressRejectButton(cell: MembershipsTableViewCell)
}


class MembershipsTableViewCell: UITableViewCell {
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var approveButton: UIButton!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    var delegate: MembershipsTableViewCellDelegate?
    
    @IBAction func approveButtonPressed(sender: UIButton) {
        delegate?.membershipTableViewCellDidPressApproveButton(self)
    }
    
    @IBAction func rejectButtonPressed(sender: UIButton) {
        delegate?.membershipTableViewCellDidPressRejectButton(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
    }
}
