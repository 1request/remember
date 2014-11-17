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
    
    @IBOutlet weak var visitTypeLabel: UILabel!
    
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateEntryDetails()
        updateExitDetails()
        updateVisitDetails()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentLocation:", name: kGPSLocationUpdateNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateEntryDetails", name: kEnteredRegionNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateExitDetails", name: kExitedRegionNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateVisitDetails", name: kVisitsNotificationName, object: nil)
        if let location = LocationManager.sharedInstance.currentLocation {
            currentLocationLabel.text = location.coordinate.printCoordinate()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateCurrentLocation(notification: NSNotification) {
        if let dict = notification.userInfo as? [String: CLLocation] {
            if let location = dict[kGPSLocationUpdateNotificationUserInfoLocationKey] {
                currentLocationLabel.text = location.coordinate.printCoordinate()
            }
        }
    }
    
    func updateEntryDetails() {
        if let dict = NSUserDefaults.standardUserDefaults().valueForKey(kEnteredGeoEventTitle) as? [String: NSObject] {
            entryRegionNameLabel.text = dict[kIdentifier] as? String
            let coordinate = CLLocationCoordinate2D(latitude: dict[kSceneLatitude] as Double, longitude: dict[kSceneLongitude] as Double)
            entryCoordinateLabel.text = coordinate.printCoordinate()
            let distance = (dict[kDistance] as Double).format("0.03")
            entryDistanceLabel.text = "\(distance)km"
            entryDateLabel.text = (dict[kDate] as? NSDate)?.dateStringOfLocalTimeZone()
        }
    }
    
    func updateExitDetails() {
        if let dict = NSUserDefaults.standardUserDefaults().valueForKey(kExitedGeoEventTitle) as? [String: NSObject] {
            let type = dict[kRegionType] as String
            if type == RegionType.Geographic.rawValue {
                exitRegionNameLabel.text = dict[kIdentifier] as? String
                let coordinate = CLLocationCoordinate2D(latitude: dict[kSceneLatitude] as Double, longitude: dict[kSceneLongitude] as Double)
                exitCoordinateLabel.text = coordinate.printCoordinate()
                let distance = (dict[kDistance] as Double).format("0.03")
                exitDistanceLabel.text = "\(distance)km"
                exitDateLabel.text = (dict[kDate] as? NSDate)?.dateStringOfLocalTimeZone()
            }
        }
    }
    
    func updateVisitDetails() {
        if let dict = NSUserDefaults.standardUserDefaults().valueForKey("Visit") as? [String: NSObject] {
            let visitCoordinate = CLLocationCoordinate2D(latitude: dict[kVisitLatitude] as Double, longitude: dict[kVisitLongitude] as Double)
            let coordinate = CLLocationCoordinate2D(latitude: dict[kSceneLatitude] as Double, longitude: dict[kSceneLongitude] as Double)
            visitCoordinateLabel.text = visitCoordinate.printCoordinate()
            visitTriggerCoordinateLabel.text = coordinate.printCoordinate()
            let distance = (dict[kDistance] as Double).format("0.03")
            visitDistanceLabel.text = "\(distance)km"
            visitDateLabel.text = (dict[kDate] as? NSDate)?.dateStringOfLocalTimeZone()
            visitTypeLabel.text = dict[kVisitType] as? String
        }
    }
}
