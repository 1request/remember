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
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    var membershipsVC: MembershipsTableViewController?
    var mapVC: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editGroupNameTextField.text = group?.name
        groupTypeTextLabel.text = group?.type
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if group?.type == "personal" {
            mapViewContainer.hidden = false
        } else {
            mapViewContainer.hidden = true
        }
        
        if group?.location == nil {
            if let l = Location.locationFromCurrentCoordinate(group!.managedObjectContext!) {
                group?.location = l
                group?.managedObjectContext?.save(nil)
                updateMap()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedMemberships" {
            membershipsVC = segue.destinationViewController as? MembershipsTableViewController
            membershipsVC?.group = self.group
        } else if segue.identifier == "embedMap" {
            mapVC = segue.destinationViewController as? MapViewController
            updateMap()
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
    
    func updateMap() {
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(group!.location.latitude), longitude: CLLocationDegrees(group!.location.longitude))
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapVC?.annotations = [annotation]
        mapVC?.region = region
    }
}
