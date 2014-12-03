//
//  AddGroupViewController.swift
//  remember
//
//  Created by Joseph Cheung on 10/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit

class AddGroupViewController: UIViewController, UITextFieldDelegate {
    var location: CLLocation? = nil
    var beacon: CLBeacon? = nil
    weak var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        groupNameTextField.delegate = self
    }
    
    func mapAnnotation() -> MKPointAnnotation {
        var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        if beacon != nil {
            if let currentLocation = LocationManager.sharedInstance.currentLocation {
                coordinate = currentLocation.coordinate
            }
        } else {
            if let gpsLocation = location {
                coordinate = gpsLocation.coordinate
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
        if countElements(groupNameTextField.text.trimWhiteSpace()) > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
    
    @IBAction func saveBarButtonItemPressed(sender: UIBarButtonItem) {
        let groupToBeAdded = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: managedObjectContext!) as Group
        groupToBeAdded.name = groupNameTextField.text
        groupToBeAdded.createdAt = NSDate()
        groupToBeAdded.updatedAt = groupToBeAdded.createdAt
        var locationToBeAdded: Location?
        if let beaconDetected = beacon {
            let location = Location.findOrCreateBy(["uuid": beaconDetected.proximityUUID.UUIDString, "major": beaconDetected.major, "minor": beaconDetected.minor], context: managedObjectContext!)
            groupToBeAdded.location = location
        } else if let locationDetected = location {
            let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext!) as Location
            newLocation.longitude = locationDetected.coordinate.longitude
            newLocation.latitude = locationDetected.coordinate.latitude
            newLocation.uuid = ""
            newLocation.major = 0
            newLocation.minor = 0
            newLocation.createdAt = NSDate()
            newLocation.updatedAt = newLocation.createdAt
            newLocation.identifier = newLocation.createIndentifier()
            groupToBeAdded.location = newLocation
        }
        
        let groupEvent = AddGroupEvent(group: groupToBeAdded)
        
        Mixpanel.sharedInstance().track(kAddGroupEventTitle, properties: groupEvent.properties)
        
        managedObjectContext!.save(nil)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
