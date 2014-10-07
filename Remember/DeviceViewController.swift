//
//  DeviceViewController.swift
//  Remember
//
//  Created by Kaeli Lo on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addDeviceDidPress(sender: UIButton) {
        performSegueWithIdentifier("showDeviceAdd", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("deviceCell") as DeviceCell
        if indexPath.row == 0 {
            cell.nameLabel.text = "EQUIPMENT457132"
            cell.distanceLabel.text = "100CM以內"
            cell.showAddDeviceButton()
        } else {
            cell.nameLabel.text = "EQUIPMENT1573"
            cell.distanceLabel.text = "100CM以內"
            cell.showAddedDeviceLabel()
        }
        
        return cell
    }
    
}
