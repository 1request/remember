//
//  LocationManager.swift
//  remember
//
//  Created by Joseph Cheung on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreLocation

let kEnteredBeaconRegionNotificationName = "enteredBeaconNotification"
let kEnteredBeaconRegionNotificationUserInfoRegionKey = "region"
let kExitedBeaconRegionNotificationName = "exitedBeaconNotification"
let kExitedBeaconRegionNotificationUserInfoRegionKey = "region"
let kRangedBeaconRegionNotificationName = "rangedBeaconNotification"
let kRangedBeaconRegionNotificationUserInfoBeaconsKey = "beacons"
let kGPSLocationUpdateNotificationName = "gpsLocationUpdateNotification"
let kGPSLocationUpdateNotificationUserInfoLocationKey = "location"

class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager = CLLocationManager()
    var locationAuthorized = false
    class var sharedInstance: LocationManager {
    struct SharedInstance {
        static let instance = LocationManager()
        }
        return SharedInstance.instance
    }
    
    override init() {
        super.init()
        let requestAlwaysAuthorization = locationManager.respondsToSelector(Selector("requestAlwaysAuthorization"))
        if requestAlwaysAuthorization {
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        if isLocationAllowed() {
            locationManager.delegate = self
            
        }
    }
    
    func startRangingBeaconRegions (beaconRegions: [CLBeaconRegion]) {
        if !CLLocationManager.isRangingAvailable() {
            println("Couldn't turn on region ranging: Region ranging is not available for this device.")
            return
        }
        for beaconRegion: CLBeaconRegion in beaconRegions {
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    func stopRangingBeaconRegions (beaconRegions: [CLBeaconRegion]) {
        for beaconRegion: CLBeaconRegion in beaconRegions {
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func startMonitoringRegions (regions: [CLRegion]) {
        if !CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) {
            println("Couldn't turn on beacon region monitoring: Region monitoring is not available for this device.")
        }
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            println("Couldn't turn on gps region monitoring: Region monitoring is not available for this device.")
        }
        for region in regions {
            self.locationManager.startMonitoringForRegion(region)
        }
    }
    
    func stopMonitoringRegions (regions: [CLRegion]) {
        for region in regions {
            self.locationManager.stopMonitoringForRegion(region)
        }
    }
    
    func isLocationAllowed () -> Bool {
        if CLLocationManager.locationServicesEnabled() == false {
            return false
        }
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
            return false
        }
        return true
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        if !beacons.isEmpty {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kRangedBeaconRegionNotificationName, object: self, userInfo: [kRangedBeaconRegionNotificationUserInfoBeaconsKey: beacons]))
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("did enter region: \(region)")
        if let beaconRegion = region as? CLBeaconRegion {
            if beaconRegion.major != nil && beaconRegion.minor != nil {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kEnteredBeaconRegionNotificationName, object: self, userInfo: [kEnteredBeaconRegionNotificationUserInfoRegionKey: beaconRegion as CLRegion]))
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kEnteredBeaconRegionNotificationName, object: self, userInfo: [kEnteredBeaconRegionNotificationUserInfoRegionKey: region as CLRegion]))
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("did exit region: \(region)")
        if let beaconRegion = region as? CLBeaconRegion {
            if beaconRegion.major != nil && beaconRegion.minor != nil {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kExitedBeaconRegionNotificationName, object: self, userInfo: [kExitedBeaconRegionNotificationUserInfoRegionKey: beaconRegion]))
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kExitedBeaconRegionNotificationName, object: self, userInfo: [kExitedBeaconRegionNotificationUserInfoRegionKey: region as CLRegion]))
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            let notification = NSNotification(name: kGPSLocationUpdateNotificationName, object: self, userInfo: [kGPSLocationUpdateNotificationUserInfoLocationKey: location])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
}