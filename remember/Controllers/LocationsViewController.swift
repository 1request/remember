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
    
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapContainerView: UIView!
    
    var locationsTVC: LocationsTableViewController?
    var mapVC: MapViewController?
    
    var selectedCoordinate: CLLocationCoordinate2D? = nil {
        didSet(oldCoordinate) {
            showMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if locationsTVC == nil {
            setUpLocationsTVC()
        }
    }
    
    func setContainerViewConstraints(containerViewController: UIViewController, view: UIView) {
        containerViewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        let viewsDict = ["controllerView": containerViewController.view]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[controllerView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[controllerView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
    
    func setUpLocationsTVC() {
        locationsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("locationsTableViewController") as? LocationsTableViewController
        addChildViewController(locationsTVC!)
        locationsContainerView.addSubview(locationsTVC!.view)
        setContainerViewConstraints(locationsTVC!, view: locationsContainerView)
        locationsTVC?.didMoveToParentViewController(self)
        locationsTVC?.delegate = self
    }
    
    func setUpMapVC() {
        mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("mapViewController") as? MapViewController
        addChildViewController(mapVC!)
        mapContainerView.addSubview(mapVC!.view)
        setContainerViewConstraints(mapVC!, view: mapContainerView)
        mapVC?.didMoveToParentViewController(self)
    }
    
    func showMap() {
        if mapVC == nil {
            setUpMapVC()
        }
        if mapViewHeightConstraint.constant == 0 {
            mapViewHeightConstraint.constant = view.bounds.size.width / 2
            updateViewConstraints()
            view.setNeedsLayout()
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate!
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        mapVC?.annotations = [annotation]
        mapVC?.region = region
        mapVC?.setMap()
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
        }
    }
}

extension LocationsViewController: LocationsTableViewControllerDelegate {
    func didSelectLocationWithCoordinate(coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
    }
    
    func didAddLocation(location: CLLocation) {
        performSegueWithIdentifier("toAddGroup", sender: location)
    }
    
    func didAddBeacon(beacon: CLBeacon) {
        performSegueWithIdentifier("toAddGroup", sender: beacon)
    }
}
