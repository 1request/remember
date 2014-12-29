//
//  MembershipsTableViewController.swift
//  remember
//
//  Created by Joseph Cheung on 24/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class MembershipsTableViewController: UITableViewController {
    
    var group: Group? = nil {
        didSet {
            group?.fetchApplyingMemberships({ [weak self](members) -> Void in
                if let weakself = self {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        weakself.applyingMembersJson = members
                    })
                }
            })
        }
    }
    
    var applyingMembersJson: [JSON]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.removeFooterBorder()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let applyingMembers = applyingMembersJson {
            return applyingMembers.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("membershipsCell", forIndexPath: indexPath) as MembershipsTableViewCell
        if let applyingMembers = applyingMembersJson {
            let imageUrl = NSURL(string: applyingMembers[indexPath.row]["profile_picture_url"].stringValue)!
            cell.profileImageView.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "device"))
            cell.usernameLabel.text = applyingMembers[indexPath.row]["nickname"].stringValue
        }
        
        cell.delegate = self
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
}

extension MembershipsTableViewController: MembershipsTableViewCellDelegate {

    func membershipTableViewCellDidPressApproveButton(cell: MembershipsTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let userId = applyingMembersJson![indexPath.row]["id"].intValue
            if let id = group?.serverId {
                let membership = Membership(groupId: id.integerValue, userId: userId)
                membership.approve() {
                    cell.approveButton.hidden = true
                    cell.rejectButton.hidden = true
                    cell.statusLabel.hidden = false
                    cell.statusLabel.text = NSLocalizedString("APPROVED", comment: "approved status text")
                }
            }
        }
    }
    
    func membershipTableViewCellDidPressRejectButton(cell: MembershipsTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let userId = applyingMembersJson![indexPath.row]["id"].intValue
            if let id = group?.serverId {
                let membership = Membership(groupId: id.integerValue, userId: userId)
                membership.reject() {
                    cell.approveButton.hidden = true
                    cell.rejectButton.hidden = true
                    cell.statusLabel.hidden = false
                    cell.statusLabel.text = NSLocalizedString("REJECTED", comment: "rejected status text")
                }
            }
        }
    }
}