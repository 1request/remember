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
    
    lazy var overlay: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        return view
    }()
    
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
        addGroupTVC?.createGroup()
        if let shareRadioButton = addGroupTVC?.sharedRadioButton {
            if shareRadioButton.checked {
                if NSUserDefaults.standardUserDefaults().valueForKey("userId") == nil {
                    showSignUpForm()
                } else {
                    addGroupTVC?.group?.createPrivateGroupInServer()
                    navigationController?.popToRootViewControllerAnimated(true)
                }
            } else {
                navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func showSignUpForm() {
        signUpContainer.hidden = false
        signUpContainer.showAnimated()
        view.insertSubview(overlay, aboveSubview: addGroupContainer)
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
        overlay.removeFromSuperview()
    }
    
    func confirmButtonClicked() {
        signUpVC?.group = addGroupTVC?.group
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
