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
    
    var devicesTVC: DevicesTableViewController?
    var mapVC: MapViewController?
    
    var selectedCoordinate: CLLocationCoordinate2D? = nil {
        didSet(oldCoordinate) {
            showMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if devicesTVC == nil {
            setUpDevicesTVC()
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
    
    func setUpDevicesTVC() {
        devicesTVC = self.storyboard?.instantiateViewControllerWithIdentifier("devicesTableViewController") as? DevicesTableViewController
        addChildViewController(devicesTVC!)
        locationsContainerView.addSubview(devicesTVC!.view)
        setContainerViewConstraints(devicesTVC!, view: locationsContainerView)
        devicesTVC?.didMoveToParentViewController(self)
        devicesTVC?.delegate = self
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
        if segue.identifier == "toAddDevice" {
            let addDeviceVC = segue.destinationViewController as AddDeviceViewController
            addDeviceVC.managedObjectContext = managedObjectContext
            if let object = sender as? CLLocation {
                addDeviceVC.location = object
            }
            if let object = sender as? CLBeacon {
                addDeviceVC.beacon = object
            }
        }
    }
}

extension LocationsViewController: DevicesTableViewControllerDelegate {
    func didSelectLocationWithCoordinate(coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
    }
    
    func didAddLocation(location: CLLocation) {
        performSegueWithIdentifier("toAddDevice", sender: location)
    }
    
    func didAddBeacon(beacon: CLBeacon) {
        performSegueWithIdentifier("toAddDevice", sender: beacon)
    }
}
