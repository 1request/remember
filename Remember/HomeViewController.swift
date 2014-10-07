//
//  HomeViewController.swift
//  Remember
//
//  Created by Kaeli Lo on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var navBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleImage = UIImage(named: "title")
        let titleView = UIImageView(image: titleImage)
        navBar.titleView = titleView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addDeviceDidPress(sender: AnyObject) {
        performSegueWithIdentifier("showDevices", sender: self)
    }

    // UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = LocationCell()
        cell.nameLabel.text = "Home"
        
        return cell
    }
    
}
