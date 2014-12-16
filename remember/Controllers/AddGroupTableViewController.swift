//
//  AddGroupTableViewController.swift
//  remember
//
//  Created by Joseph Cheung on 3/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@objc protocol AddGroupTableViewControllerDelegate {
    func groupNameTextFieldDidChange(textField: UITextField)
}

class AddGroupTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    weak var managedObjectContext: NSManagedObjectContext?
    
    var location: CLLocation? = nil
    var beacon: CLBeacon? = nil

    @IBOutlet weak var groupNameTextField: UITextField!
    
    @IBOutlet weak var ownRadioButton: RadioButton!
    
    @IBOutlet weak var sharedRadioButton: RadioButton!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    weak var delegate: AddGroupTableViewControllerDelegate?

    var group: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ownRadioButton.checked = true
        tableView.removeFooterBorder()
        groupNameTextField.delegate = self
        saveButton.enabled = false
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.cancelsTouchesInView = false
        groupNameTextField.becomeFirstResponder()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            ownRadioButton.checked = true
            sharedRadioButton.checked = false
        } else if indexPath.row == 2 {
            sharedRadioButton.checked = true
            ownRadioButton.checked = false
        }
    }

    @IBAction func groupNameTextFieldEditingChanged(sender: UITextField) {
        delegate?.groupNameTextFieldDidChange(sender)
    }
    
    func createGroup() {
        let groupToBeAdded = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: managedObjectContext!) as Group
        groupToBeAdded.name = groupNameTextField.text
        groupToBeAdded.createdAt = NSDate()
        groupToBeAdded.updatedAt = groupToBeAdded.createdAt
        
        if ownRadioButton.checked {
            groupToBeAdded.type = "personal"
        } else {
            groupToBeAdded.type = "private"
        }
        
        var locationToBeAdded: Location?
        if let beaconDetected = beacon {
            let beacon = Location.findOrCreateBy(beaconDetected.proximityUUID.UUIDString, major: beaconDetected.major, minor: beaconDetected.minor, context: managedObjectContext!)
            
            if let currentLocation = LocationManager.sharedInstance.currentLocation {
                beacon.longitude = currentLocation.coordinate.longitude
                beacon.latitude = currentLocation.coordinate.latitude
            }
            
            groupToBeAdded.location = beacon
        } else if let locationDetected = location {
            let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext!) as Location
            newLocation.longitude = locationDetected.coordinate.longitude
            newLocation.latitude = locationDetected.coordinate.latitude
            newLocation.uuid = ""
            newLocation.major = 0
            newLocation.minor = 0
            newLocation.createdAt = NSDate()
            newLocation.updatedAt = newLocation.createdAt
            newLocation.createIndentifier()
            groupToBeAdded.location = newLocation
        }
        
        let groupEvent = AddGroupEvent(group: groupToBeAdded)
        
        Mixpanel.sharedInstance().track(kAddGroupEventTitle, properties: groupEvent.properties)
        
        managedObjectContext!.save(nil)
        
        group = groupToBeAdded
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

extension AddGroupTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}