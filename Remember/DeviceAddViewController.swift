//
//  DeviceAddViewController.swift
//  Remember
//
//  Created by Kaeli Lo on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class DeviceAddViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveDidPress(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
