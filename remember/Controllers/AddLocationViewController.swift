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
import QuartzCore

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
        signUpVC?.delegate = self
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
        if let shareRadioButton = addGroupTVC?.sharedRadioButton {
            if shareRadioButton.checked {
                if !User.isRegistered() {
                    showSignUpForm()
                } else {
                    addGroupTVC?.createGroup()
                    addGroupTVC?.group?.createPrivateGroupInServer() { [weak self] in
                        if let weakself = self {
                            weakself.navigationController?.popToRootViewControllerAnimated(true)
                        }
                    }
                }
            } else {
                addGroupTVC?.createGroup()
                navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func showSignUpForm() {
        signUpContainer.hidden = false
        signUpContainer.showAnimated()
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

extension AddLocationViewController: SignUpViewControllerDelegate {
    func cancelButtonClicked() {
        signUpContainer.dismissAnimated()
    }
    
    func didCreateUser() {
        addGroupTVC?.createGroup()
        addGroupTVC?.group?.createPrivateGroupInServer() { [weak self] in
            if let weakself = self {
                weakself.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
}
