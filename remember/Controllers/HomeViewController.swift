//
//  HomeViewController.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var managedObjectContext = NSManagedObjectContext()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add remember logo to navigation bar
        let logo = UIImage(named: "remember-logo")
        let logoImageView = UIImageView(image: logo)
        self.navigationItem.titleView = logoImageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("locationsCell", forIndexPath: indexPath) as LocationsTableViewCell
            cell.locationNameLabel.text = "My office"
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("messagesCell", forIndexPath: indexPath) as MessagesTableViewCell
            cell.messageLabel.text = "Record " + String(indexPath.row)
            return cell
        }
    }
    
    // UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is LocationsTableViewCell {
            var locationCell: LocationsTableViewCell = cell as LocationsTableViewCell
            if locationCell.isChecked() {
                locationCell.uncheckedRadioButton()
            } else {
                locationCell.checkRadioButton()
            }
        } else {
            var messageCell: MessagesTableViewCell = cell as MessagesTableViewCell
            if messageCell.playing {
                messageCell.finishPlaying()
            } else {
                messageCell.startPlaying()
            }
        }
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let devicesVC = segue.destinationViewController as? DevicesTableViewController {
            devicesVC.managedObjectContext = self.managedObjectContext
        }
    }
}
