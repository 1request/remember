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
    weak var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var deviceNameTextField: UITextField!
    
    
    @IBAction func saveBarButtonItemPressed(sender: UIBarButtonItem) {
        let location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext!) as Location
        location.name = deviceNameTextField.text
        location.uuid = beacon.proximityUUID.UUIDString
        location.major = beacon.major
        location.minor = beacon.minor
        location.createdAt = NSDate()
        location.updatedAt = location.createdAt
        
        managedObjectContext!.save(nil)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
