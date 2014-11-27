//
//  MapViewController.swift
//  remember
//
//  Created by Joseph Cheung on 27/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var annotations: [MKPointAnnotation]? = nil
    var region: MKCoordinateRegion? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if region != nil {
            setMap()
        }
    }
    
    func setMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
        mapView.region = region!
    }
}
