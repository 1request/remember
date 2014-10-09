//
//  HomeViewController.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add remember logo in navigation bar
        let logo = UIImage(named: "remember-logo")
        let logoImageView = UIImageView(image: logo)
        self.navigationItem.titleView = logoImageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
