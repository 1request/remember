//
//  InterfaceController.swift
//  Remember WatchKit Extension
//
//  Created by Joseph Cheung on 19/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var locationTable: WKInterfaceTable!
    
    override init(context: AnyObject?) {
        super.init(context: context)
        loadData()
        let timer = NSTimer(timeInterval: 3, target: self, selector: "loadData", userInfo: nil, repeats: true)
        timer.fire()
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    func loadData() {
        let userDefaults = NSUserDefaults(suiteName: "group.remember")
        let locations = userDefaults?.valueForKey("locations") as [String: [String]]
        locationTable.setNumberOfRows(locations.count, withRowType: "location")
        for (locationName, _) in locations {
            let arr = Array(locations.keys)
            let index = find(arr, locationName)!
            let row = locationTable.rowControllerAtIndex(index) as LocationRowController
            row.nameLabel.setText(locationName)
        }
    }
    
    func updateExtension() {
        loadData()
    }
}
