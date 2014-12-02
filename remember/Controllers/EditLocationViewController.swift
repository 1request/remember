//
//  EditLocationViewController.swift
//  remember
//
//  Created by Joseph Cheung on 5/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class EditLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editLocationNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    weak var managedObjectContext: NSManagedObjectContext?
    var location:Location? = nil
    
    lazy var annotation: MKPointAnnotation? = {
        if let currentLocation = self.location {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentLocation.latitude), longitude: CLLocationDegrees(currentLocation.longitude))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            return annotation
        } else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editLocationNameTextField.text = location?.name
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
    
    @IBAction func locationNameEditingChanged(sender: UITextField) {
        if countElements(sender.text.trimWhiteSpace()) > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        location?.name = editLocationNameTextField.text
        var error: NSError? = nil
        if !managedObjectContext!.save(&error) {
            println("Cannot update location: \(error)")
        }
        navigationController?.popViewControllerAnimated(true)
    }
}
