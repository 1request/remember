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
    
    @IBOutlet weak var creatorImageView: UIImageView!
    
    @IBAction func addButtonPressed(sender: UIButton) {
        performAddAction(sender)
    }
    
    func setAsApplied() {
        addButton.setTitle(SENT, forState: .Normal)
        addButton.enabled = false
        addButton.backgroundColor = UIColor.appGrayColor()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if let image = creatorImageView.image {
            let mask = CALayer()
            let maskImage = UIImage(named: "hexagon-frame")!
            mask.contents = maskImage.CGImage
            mask.frame = CGRectMake(0, 0, creatorImageView.frame.size.width, creatorImageView.frame.size.height)
            creatorImageView.layer.mask = mask
            creatorImageView.layer.masksToBounds = true
        }
    }
}
