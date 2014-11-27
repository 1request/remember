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
import MapKit

class AddDeviceViewController: UIViewController, UITextFieldDelegate {
    var location: CLLocation? = nil
    var beacon: CLBeacon? = nil
    weak var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var deviceNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    


    override func viewDidLoad() {
        deviceNameTextField.delegate = self
    }
    
    func mapAnnotation() -> MKPointAnnotation {
        var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        if beacon != nil {
            if let currentLocation = LocationManager.sharedInstance.currentLocation {
                coordinate = currentLocation.coordinate
            }
        } else {
            if let locationToBeAdded = location {
                coordinate = locationToBeAdded.coordinate
            }
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedMapFromAddLocation" {
            let mapViewController = segue.destinationViewController as MapViewController
            let annotation = mapAnnotation()
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegionMake(annotation.coordinate, span)
            mapViewController.region = region
            mapViewController.annotations = [annotation]
        }
    }
    
    @IBAction func deviceNameTextEditingChanged(sender: AnyObject) {
        if deviceNameTextField.text == "" {
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
    }
    
    @IBAction func saveBarButtonItemPressed(sender: UIBarButtonItem) {
        let locationToBeAdded = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext!) as Location
        locationToBeAdded.name = deviceNameTextField.text
        
        
        if let beaconDetected = beacon {
            locationToBeAdded.uuid = beaconDetected.proximityUUID.UUIDString
            locationToBeAdded.major = beaconDetected.major
            locationToBeAdded.minor = beaconDetected.minor
            if let currentLocation = LocationManager.sharedInstance.currentLocation {
                locationToBeAdded.longitude = currentLocation.coordinate.longitude
                locationToBeAdded.latitude = currentLocation.coordinate.latitude
            } else {
                locationToBeAdded.longitude = 0
                locationToBeAdded.latitude = 0
            }
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
        let event = AddLocationEvent(location: locationToBeAdded)
        
        Mixpanel.sharedInstance().track(event.title, properties: event.properties)
        
        managedObjectContext!.save(nil)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
