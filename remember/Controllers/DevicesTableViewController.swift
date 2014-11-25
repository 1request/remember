//
//  DevicesTableViewController.swift
//  remember
//
//  Created by Joseph Cheung on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class DevicesTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    let LOADING_LOCATION = NSLocalizedString("LOADING_LOCATION", comment: "gps cell label text when loading location")
    let CURRENT_LOCATION = NSLocalizedString("CURRENT_LOCATION", comment: "gps cell label text when location is determined")
    let WITHIN_RANGE = NSLocalizedString("WITHIN_RANGE", comment: "Meter range of beacon")
    let ADDED = NSLocalizedString("ADDED", comment: "beacon has been added")
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var rangedBeacons = [CLBeacon]()
    var gpsLocation:CLLocation? = nil {
        willSet(newLocation) {
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(self, name: kRangedBeaconRegionNotificationName, object: nil)
        notificationCenter.removeObserver(self, name: kGPSLocationUpdateNotificationName, object: nil)
    }
    
    //MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return rangedBeacons.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
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
                    self?.performSegueWithIdentifier("toAddDevice", sender: location)
                }
            }
            return cell
        } else {
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
                        weakSelf.performSegueWithIdentifier("toAddDevice", sender: beacon)
                    }
                }
            }
            
            cell.rangeLabel.text = String(format: WITHIN_RANGE, formattedRange)
            return cell
        }
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let addDeviceViewController = segue.destinationViewController as? AddDeviceViewController {
            addDeviceViewController.managedObjectContext = managedObjectContext!
            if let beacon = sender as? CLBeacon {
                addDeviceViewController.beacon = beacon
            } else if let location = sender as? CLLocation {
                addDeviceViewController.location = location
            }
        }
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
                    tableView.reloadData()
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