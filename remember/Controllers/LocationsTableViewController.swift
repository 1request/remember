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
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var rangedBeacons = [CLBeacon]()
    weak var delegate: LocationsTableViewControllerDelegate?
    var gpsLocation:CLLocation? = nil {
        didSet(oldLocation) {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var gpsAddButton: UIButton!
    
    weak var managedObjectContext:NSManagedObjectContext?
    
    var fetchedGroups = [[String: AnyObject]]()
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
        
//        Group.fetchGroupsFromServerInContext(managedObjectContext!) { [weak self] (groups, locations, statuses) -> Void in
//            if let weakself = self {
//                weakself.groups = groups
//                weakself.groupLocations = locations
//                weakself.groupStatuses = statuses
//                dispatch_async(dispatch_get_main_queue()) {
//                    weakself.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
//                }
//            }
//        }
        Group.fetchGroupsFromServer { [weak self](groups) -> Void in
            if let weakself = self {
                weakself.fetchedGroups = groups
                dispatch_async(dispatch_get_main_queue()) {
                    weakself.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
                }
            }
        }
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
            return fetchedGroups.count
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
        let group = fetchedGroups[indexPath.row]
        let longitude = group["longitude"] as Double
        let latitude = group["latitude"] as Double
        let coordinate = CLLocation(latitude: latitude, longitude: longitude)
        let formattedRange = coordinate.distanceFromLocation(gpsLocation).format(".2")
        let range = String(format: WITHIN_RANGE, formattedRange)
        cell.nameLabel.text = group["name"] as? String
        cell.addressLabel.text = range
        cell.addressLabel.sizeToFit()
        let url = NSURL(string: group["url"] as String)!
        let placeholderImage = UIImage(named: "device")!
        
        cell.creatorImageView.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.CacheMemoryOnly)
        
        if group["status"] as String == "applying" {
            cell.setAsApplied()
        }
        
        cell.didPressAddButtonBlock = {
            [weak self] in
            if let weakself = self {
                cell.setAsApplied()
                if User.isRegistered() {
                    Group.join(group["id"] as Int)
                } else {
                    println("register user")
                }
            }
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
        
        cell.didPressAddButtonBlock = {
            [weak self, beacon] in
            if let weakSelf = self {
                weakSelf.delegate?.didAddBeacon(beacon)
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