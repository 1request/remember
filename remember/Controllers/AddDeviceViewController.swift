//
//  AddDeviceViewController.swift
//  remember
//
//  Created by Joseph Cheung on 10/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class AddDeviceViewController: UIViewController {

    var beacon = CLBeacon()
    var managedObjectContext = NSManagedObjectContext()
    
    @IBOutlet weak var deviceNameTextField: UITextField!
    
    
    @IBAction func saveBarButtonItemPressed(sender: UIBarButtonItem) {
        let location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.managedObjectContext) as Location
        location.name = self.deviceNameTextField.text
        location.uuid = self.beacon.proximityUUID.UUIDString
        location.major = self.beacon.major
        location.minor = self.beacon.minor
        location.createdAt = NSDate()
        location.updatedAt = location.createdAt
        
        self.managedObjectContext.save(nil)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
