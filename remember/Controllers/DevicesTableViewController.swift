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
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var rangedBeacons = [CLBeacon]()
    var managedObjectContext:(NSManagedObjectContext) = NSManagedObjectContext() {
        didSet {
            let request = NSFetchRequest(entityName: "Location")
            request.fetchBatchSize = 20
            var error: NSError? = nil;
            locations = self.managedObjectContext.executeFetchRequest(request, error: &error) as [Location]
        }
    }
    var locations = [Location]()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        LocationManager.sharedInstance.startRangingBeaconRegions(BeaconFactory.beaconRegionsToBeRanged())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(self, selector: Selector("enteredRegion:"), name: kRangedBeaconRegionNotificationName, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(self, name: kRangedBeaconRegionNotificationName, object: nil)
    }
    
    //MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rangedBeacons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:DevicesTableViewCell = tableView.dequeueReusableCellWithIdentifier("devicesCell", forIndexPath: indexPath) as DevicesTableViewCell
        
        let beacon = self.rangedBeacons[indexPath.row]
        
        cell.nameLabel.text = (beacon.proximityUUID.UUIDString as NSString).substringToIndex(8)
        
        let formattedRange = beacon.accuracy.format(".2")
    
        let predicate = NSPredicate(format: "uuid == %@ AND major == %@ AND minor == %@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor)
        
        let filteredLocations = self.locations.filter { predicate.evaluateWithObject($0) }
        
        if !filteredLocations.isEmpty {
            cell.addButton.setTitle("Added", forState: UIControlState.Normal)
            cell.addButton.setTitleColor(UIColor.appGreyColor(), forState: UIControlState.Normal)
            cell.addButton.backgroundColor = nil

        }
        else {
            cell.didPressAddButtonBlock = {
                self.performSegueWithIdentifier("toAddDevice", sender: beacon)
            }
        }
        
        cell.rangeLabel.text = "Within \(formattedRange)m"
        
        return cell
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let beacon = sender as? CLBeacon {
            if let addDeviceViewController = segue.destinationViewController as? AddDeviceViewController {
                addDeviceViewController.beacon = beacon
                addDeviceViewController.managedObjectContext = self.managedObjectContext
            }
        }
    }
    
    //MARK: - NSNotification
    
    func enteredRegion (notification: NSNotification) {
        if let dict = notification.userInfo as? Dictionary<String, [AnyObject]> {
            if let beacons = dict[kRangedBeaconRegionNotificationUserInfoBeaconsKey] {
                let count = self.rangedBeacons.count
                for object in beacons {
                    let beacon = object as CLBeacon
                    let predicate = NSPredicate(format: "proximityUUID.UUIDString == %@ AND major == %@ AND minor == %@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor)
                    let filteredArray = self.rangedBeacons.filter { predicate.evaluateWithObject($0) }
                    if filteredArray.isEmpty {
                        self.rangedBeacons.append(beacon)
                    }
                }
                if self.rangedBeacons.count > count {
                    self.tableView.reloadData()
                }
            }
        }
    }
}