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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editLocationNameTextField.text = location?.name
        setMap()
    }
    
    func setMap() {
        if let currentLocation = location {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentLocation.latitude), longitude: CLLocationDegrees(currentLocation.longitude))
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegionMake(coordinate, span)
            mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func locationNameEditingChanged(sender: UITextField) {
        if editLocationNameTextField.text == "" {
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
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
