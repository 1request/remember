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

class AddGroupTableViewController: UITableViewController {
    
    weak var managedObjectContext: NSManagedObjectContext?
    
    var location: CLLocation? = nil
    var beacon: CLBeacon? = nil

    @IBOutlet weak var groupNameTextField: UITextField!
    
    @IBOutlet weak var ownRadioButton: RadioButton!
    
    @IBOutlet weak var sharedRadioButton: RadioButton!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ownRadioButton.checked = true
        tableView.removeFooterBorder()
        groupNameTextField.delegate = self
        saveButton.enabled = false
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
        if countElements(groupNameTextField.text.trimWhiteSpace()) > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
    
    @IBAction func saveBarButtonItemClicked(sender: UIBarButtonItem) {
        let groupToBeAdded = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: managedObjectContext!) as Group
        groupToBeAdded.name = groupNameTextField.text
        groupToBeAdded.createdAt = NSDate()
        groupToBeAdded.updatedAt = groupToBeAdded.createdAt
        
        if ownRadioButton.checked {
            groupToBeAdded.type = "personal"
        } else {
            groupToBeAdded.type = "shared"
        }
        
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
    
}

extension AddGroupTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}