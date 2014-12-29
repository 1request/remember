//
//  EditGroupViewController.swift
//  remember
//
//  Created by Joseph Cheung on 5/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class EditGroupViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editGroupNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    weak var managedObjectContext: NSManagedObjectContext?
    var group: Group? = nil
    
    @IBOutlet weak var groupTypeTextLabel: UILabel!
    
    @IBOutlet weak var membershipsContainer: UIView!
    
    var membershipsVC: MembershipsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editGroupNameTextField.text = group?.name
        groupTypeTextLabel.text = group?.type
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedMemberships" {
            membershipsVC = segue.destinationViewController as? MembershipsTableViewController
            membershipsVC?.group = self.group
        }
    }
    
    @IBAction func groupNameEditingChanged(sender: UITextField) {
        if countElements(sender.text.trimWhiteSpace()) > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        group?.name = editGroupNameTextField.text
        var error: NSError? = nil
        if !managedObjectContext!.save(&error) {
            println("Cannot update location: \(error)")
        }
        navigationController?.popViewControllerAnimated(true)
    }
}
