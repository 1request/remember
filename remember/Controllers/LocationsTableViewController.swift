//
//  LocationsTableViewController.swift
//  remember
//
//  Created by Joseph Cheung on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData
import MapKit
import AddressBookUI

@objc protocol LocationsTableViewControllerDelegate {
    func didSelectLocationWithCoordinate(coordinate: CLLocationCoordinate2D)
    func didAddLocation(location: CLLocation)
    func didAddBeacon(beacon: CLBeacon)
}

class LocationsTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    let LOADING_LOCATION = NSLocalizedString("LOADING_LOCATION", comment: "gps cell label text when loading location")
    let CURRENT_LOCATION = NSLocalizedString("CURRENT_LOCATION", comment: "gps cell label text when location is determined")
    let WITHIN_RANGE = NSLocalizedString("WITHIN_RANGE", comment: "Meter range of beacon")
    let ADDED = NSLocalizedString("ADDED", comment: "beacon has been added")
    
    var mapItems:[MKMapItem] = [MKMapItem]() {
        didSet(oldMapItems) {
            tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
        }
    }
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var rangedBeacons = [CLBeacon]()
    weak var delegate: LocationsTableViewControllerDelegate?
    var gpsLocation:CLLocation? = nil {
        didSet(oldLocation) {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var gpsAddButton: UIButton!
    
    weak var managedObjectContext:NSManagedObjectContext? {
        didSet {
            let request = NSFetchRequest(entityName: "Location")
            request.fetchBatchSize = 20
            var error: NSError? = nil
            locations = managedObjectContext!.executeFetchRequest(request, error: &error) as [Location]
        }
    }
    var locations = [Location]()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        tableView.removeFooterBorder()
        LocationManager.sharedInstance.startRangingBeaconRegions(BeaconFactory.beaconRegionsToBeRanged())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(self, selector: "enteredRegion:", name: kRangedBeaconRegionNotificationName, object: nil)
        notificationCenter.addObserver(self, selector: "updateGPSLocation:", name: kGPSLocationUpdateNotificationName, object: nil)
        gpsLocation = LocationManager.sharedInstance.currentLocation
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(self, name: kRangedBeaconRegionNotificationName, object: nil)
        notificationCenter.removeObserver(self, name: kGPSLocationUpdateNotificationName, object: nil)
    }
    
    //MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return rangedBeacons.count
        } else if section == 1 {
            return 1
        } else {
            return mapItems.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return devicesCellAtIndexPath(indexPath)
        } else if indexPath.section == 1 {
            return gpsLocationCellAtIndexPath(indexPath)
            
        } else {
            return nearbyLocationsCellAtIndexPath(indexPath)
        }
    }
    
    func nearbyLocationsCellAtIndexPath(indexPath: NSIndexPath) -> NearbyLocationsTableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("nearbyPlacesCell", forIndexPath: indexPath) as NearbyLocationsTableViewCell
        let mapItem = mapItems[indexPath.row]
        
        cell.nameLabel.text = mapItem.name
        let address = ABCreateStringWithAddressDictionary(mapItem.placemark.addressDictionary, false)
        cell.addressLabel.text = address
        cell.addressLabel.sizeToFit()
        cell.didPressAddButtonBlock = {
            [weak self, mapItem] in
            let location = CLLocation(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
            self?.delegate?.didAddLocation(location)
        }
        return cell
    }
    
    func gpsLocationCellAtIndexPath(indexPath: NSIndexPath) -> GPSLocationTableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("gpsCell", forIndexPath: indexPath) as GPSLocationTableViewCell
        if gpsLocation == nil {
            cell.label.text = LOADING_LOCATION
            cell.addButton.hidden = true
        } else {
            cell.label.text = CURRENT_LOCATION
            cell.addButton.hidden = false
        }
        cell.didPressAddButtonBlock = {
            [weak self] in
            if let location = self?.gpsLocation {
                self?.delegate?.didAddLocation(location)
            }
        }
        return cell
    }
    
    func devicesCellAtIndexPath(indexPath: NSIndexPath) -> DevicesTableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("devicesCell", forIndexPath: indexPath) as DevicesTableViewCell
        let beacon = rangedBeacons[indexPath.row]
        
        cell.nameLabel.text = (beacon.proximityUUID.UUIDString as NSString).substringToIndex(8)
        
        let formattedRange = beacon.accuracy.format(".2")
        
        let predicate = NSPredicate(format: "uuid == %@ AND major == %@ AND minor == %@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor)
        
        let filteredLocations = locations.filter { predicate!.evaluateWithObject($0) }
        
        if !filteredLocations.isEmpty {
            cell.addButton.setTitle(ADDED, forState: UIControlState.Normal)
            cell.addButton.setTitleColor(UIColor.appGrayColor(), forState: UIControlState.Normal)
            cell.addButton.backgroundColor = nil
            
        }
        else {
            cell.didPressAddButtonBlock = {
                [weak self, beacon] in
                if let weakSelf = self {
                    weakSelf.delegate?.didAddBeacon(beacon)
                }
            }
        }
        
        cell.rangeLabel.text = String(format: WITHIN_RANGE, formattedRange)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let locationsVC = parentViewController as LocationsViewController
    }
    
    //MARK: - NSNotification
    
    func enteredRegion (notification: NSNotification) {
        if let dict = notification.userInfo as? Dictionary<String, [AnyObject]> {
            if let beacons = dict[kRangedBeaconRegionNotificationUserInfoBeaconsKey] {
                let count = rangedBeacons.count
                for object in beacons {
                    let beacon = object as CLBeacon
                    let predicate = NSPredicate(format: "proximityUUID.UUIDString == %@ AND major == %@ AND minor == %@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor)
                    let filteredArray = rangedBeacons.filter { predicate!.evaluateWithObject($0) }
                    if filteredArray.isEmpty {
                        rangedBeacons.append(beacon)
                    }
                }
                if rangedBeacons.count > count {
                    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    func updateGPSLocation (notification: NSNotification) {
        if let dict = notification.userInfo as? Dictionary<String, CLLocation> {
            if let location = dict[kGPSLocationUpdateNotificationUserInfoLocationKey] {
                gpsLocation = location
            }
        }
    }
}