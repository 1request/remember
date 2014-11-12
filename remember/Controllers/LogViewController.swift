//
//  LogViewController.swift
//  remember
//
//  Created by Joseph Cheung on 12/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreLocation

class LogViewController: UIViewController {

    @IBOutlet weak var entryRegionNameLabel: UILabel!
    
    @IBOutlet weak var entryCoordinateLabel: UILabel!
    
    @IBOutlet weak var entryDistanceLabel: UILabel!
    
    @IBOutlet weak var entryDateLabel: UILabel!
    
    @IBOutlet weak var exitRegionNameLabel: UILabel!
    
    @IBOutlet weak var exitCoordinateLabel: UILabel!
    
    @IBOutlet weak var exitDistanceLabel: UILabel!
    
    @IBOutlet weak var exitDateLabel: UILabel!
    
    @IBOutlet weak var visitCoordinateLabel: UILabel!
    
    @IBOutlet weak var visitTriggerCoordinateLabel: UILabel!
    
    @IBOutlet weak var visitDistanceLabel: UILabel!
    
    @IBOutlet weak var visitDateLabel: UILabel!
    
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateEntryDetails()
        updateExitDetails()
        updateVisitDetails()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentLocation:", name: kGPSLocationUpdateNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateEntryDetails", name: kEnteredBeaconRegionNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateExitDetails", name: kExitedBeaconRegionNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateVisitDetails", name: kVisitsNotificationName, object: nil)
        if let location = LocationManager.sharedInstance.currentLocation {
            currentLocationLabel.text = location.coordinate.printCoordinate()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateCurrentLocation(notification: NSNotification) {
        if let dict = notification.userInfo as? Dictionary<String, CLLocation> {
            if let location = dict[kGPSLocationUpdateNotificationUserInfoLocationKey] {
                currentLocationLabel.text = location.coordinate.printCoordinate()
            }
        }
    }
    
    func updateEntryDetails() {
        if let dict = NSUserDefaults.standardUserDefaults().valueForKey(kEntryDetails) as? Dictionary<String, NSObject> {
            entryDateLabel.text = "\((dict[kTriggerDate] as NSDate).dateStringOfLocalTimeZone())"
            entryRegionNameLabel.text = dict[kRegionName] as? String
            entryCoordinateLabel.text = dict[kTriggerCoordinate] as? String
            entryDistanceLabel.text = dict[kTriggerDistance] as? String
        }
    }
    
    func updateExitDetails() {
        if let dict = NSUserDefaults.standardUserDefaults().valueForKey(kExitDetails) as? Dictionary<String, NSObject> {
            exitDateLabel.text = "\((dict[kTriggerDate] as NSDate).dateStringOfLocalTimeZone())"
            exitRegionNameLabel.text = dict[kRegionName] as? String
            exitCoordinateLabel.text = dict[kTriggerCoordinate] as? String
            exitDistanceLabel.text = dict[kTriggerDistance] as? String
        }
    }
    
    func updateVisitDetails() {
        if let dict = NSUserDefaults.standardUserDefaults().valueForKey(kVisitDetails) as? Dictionary<String, NSObject> {
            visitCoordinateLabel.text = dict[kVisitCoordinate] as? String
            visitTriggerCoordinateLabel.text = dict[kTriggerCoordinate] as? String
            visitDateLabel.text = "\((dict[kTriggerDate] as NSDate).dateStringOfLocalTimeZone())"
            visitDistanceLabel.text = dict[kTriggerDistance] as? String
        }
    }
}
