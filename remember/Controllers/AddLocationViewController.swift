//
//  AddLocationViewController.swift
//  remember
//
//  Created by Joseph Cheung on 4/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class AddLocationViewController: UIViewController {

    @IBOutlet weak var addGroupContainer: UIView!
    
    @IBOutlet weak var signUpContainer: UIView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    weak var managedObjectContext: NSManagedObjectContext?
    
    var location: CLLocation? = nil
    var beacon: CLBeacon? = nil
    
    var addGroupTVC: AddGroupTableViewController?
    var signUpVC: SignUpViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
        addGroupTVC?.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedSetGroup" {
            addGroupTVC = segue.destinationViewController as? AddGroupTableViewController
            addGroupTVC?.managedObjectContext = managedObjectContext
            addGroupTVC?.location = location
            addGroupTVC?.beacon = beacon
        } else if segue.identifier == "embedSignUp" {
            signUpVC = segue.destinationViewController as? SignUpViewController
        }
    }
    
    
    @IBAction func saveBarButtonItemPressed(sender: UIBarButtonItem) {
        addGroupTVC?.createGroup()
    }
}

extension AddLocationViewController: AddGroupTableViewControllerDelegate {
    func groupNameTextFieldDidChange(textField: UITextField) {
        if countElements(textField.text.trimWhiteSpace()) > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
}
