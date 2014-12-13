//
//  LocationsViewController.swift
//  remember
//
//  Created by Joseph Cheung on 27/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class LocationsViewController: UIViewController {
    weak var managedObjectContext:NSManagedObjectContext? = nil
    
    @IBOutlet weak var locationsContainerView: UIView!
    
    @IBOutlet weak var signUpContainerView: UIView!
    
    var selectedGroupId: Int?
    var locationsTVC: LocationsTableViewController?
    var signUpVC: SignUpViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationsTVC?.delegate = self
        signUpVC?.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAddGroup" {
            let addLocationVC = segue.destinationViewController as AddLocationViewController
            addLocationVC.managedObjectContext = managedObjectContext
            if let object = sender as? CLLocation {
                addLocationVC.location = object
            }
            if let object = sender as? CLBeacon {
                addLocationVC.beacon = object
            }
        } else if segue.identifier == "embedLocationsTable" {
            locationsTVC = segue.destinationViewController as? LocationsTableViewController
            locationsTVC?.managedObjectContext = managedObjectContext
        } else if segue.identifier == "embedSignUpInLocations" {
            signUpVC = segue.destinationViewController as? SignUpViewController
        }
    }
    
    func showSignUpForm() {
        signUpContainerView.hidden = false
        signUpContainerView.showAnimated()
    }
}

extension LocationsViewController: LocationsTableViewControllerDelegate {
    
    func didAddLocation(location: CLLocation) {
        performSegueWithIdentifier("toAddGroup", sender: location)
    }
    
    func didAddBeacon(beacon: CLBeacon) {
        performSegueWithIdentifier("toAddGroup", sender: beacon)
    }
    
    func newUserDidChooseGroupWithId(id: Int) {
        selectedGroupId = id
        showSignUpForm()
    }
}

extension LocationsViewController: SignUpViewControllerDelegate {
    func cancelButtonClicked() {
        signUpContainerView.hidden = true
    }
    
    func didCreateUser() {
        if let id = selectedGroupId {
            Group.join(id) { [weak self] in
                if let weakself = self {
                    weakself.locationsTVC?.fetchGroups()
                    weakself.signUpContainerView.hidden = true
                }
            }
        }
    }
}
