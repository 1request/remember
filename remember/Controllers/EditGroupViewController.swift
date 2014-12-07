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
    
    lazy var annotation: MKPointAnnotation? = {
        if let currentGroup = self.group {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentGroup.location.latitude), longitude: CLLocationDegrees(currentGroup.location.longitude))         
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            return annotation
        } else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editGroupNameTextField.text = group?.name
        groupTypeTextLabel.text = group?.type
    }
    
    func mapAnnotation() {
            }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedMapFromEditLocation" {
            let mapViewController = segue.destinationViewController as MapViewController
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegionMake(annotation!.coordinate, span)
            mapViewController.region = region
            mapViewController.annotations = [annotation!]
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
