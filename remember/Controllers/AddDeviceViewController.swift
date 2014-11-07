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
    var location: CLLocation? = nil
    var beacon: CLBeacon? = nil
    weak var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var deviceNameTextField: UITextField!
    
    
    @IBAction func saveBarButtonItemPressed(sender: UIBarButtonItem) {
        let locationToBeAdded = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext!) as Location
        locationToBeAdded.name = deviceNameTextField.text
        
        if let beaconDetected = beacon {
            locationToBeAdded.uuid = beaconDetected.proximityUUID.UUIDString
            locationToBeAdded.major = beaconDetected.major
            locationToBeAdded.minor = beaconDetected.minor
            locationToBeAdded.longitude = 0
            locationToBeAdded.latitude = 0
        } else if let locationDetected = location {
            locationToBeAdded.longitude = locationDetected.coordinate.longitude
            locationToBeAdded.latitude = locationDetected.coordinate.latitude
            locationToBeAdded.uuid = ""
            locationToBeAdded.major = 0
            locationToBeAdded.minor = 0
        }
        
        locationToBeAdded.createdAt = NSDate()
        locationToBeAdded.updatedAt = locationToBeAdded.createdAt
        
        locationToBeAdded.identifier = locationToBeAdded.createIndentifier()
        
        managedObjectContext!.save(nil)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
