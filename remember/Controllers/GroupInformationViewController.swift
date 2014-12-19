//
//  GroupInformationViewController.swift
//  remember
//
//  Created by Joseph Cheung on 18/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import MapKit

protocol GroupInformationViewControllerDelegate {
    func closeButtonPressed()
}

class GroupInformationViewController: UIViewController {

    @IBOutlet weak var groupInformationView: GroupInformationView!
    
    var delegate: GroupInformationViewControllerDelegate?
    
    var group: Group? {
        didSet {
            if let currentGroup = group {
                groupInformationView.groupNameLabel.text = currentGroup.name
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentGroup.location.latitude), longitude: CLLocationDegrees(currentGroup.location.longitude))
                println("location: \(currentGroup.location)")
                println("coordinate: \(coordinate.latitude) \(coordinate.longitude)")
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                groupInformationView.annotation = annotation
                
                let span = MKCoordinateSpanMake(0.03, 0.03)
                let region = MKCoordinateRegionMake(coordinate, span)
                groupInformationView.region = region
            }
        }
    }
    
    override func viewDidLoad() {
        groupInformationView.popUpDelegate = self
    }
}

extension GroupInformationViewController: PopUpViewDelegate {
    func closeButtonPressed() {
        delegate?.closeButtonPressed()
    }
}