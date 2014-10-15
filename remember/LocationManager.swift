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
        let requestAlwaysAuthorization = self.locationManager.respondsToSelector(Selector("requestAlwaysAuthorization"))
        if requestAlwaysAuthorization {
            self.locationManager.requestAlwaysAuthorization()
        }
        if self.isLocationAllowed() {
            self.locationManager.delegate = self
            
        }
    }
    
    func startRangingBeaconRegions (beaconRegions: [CLBeaconRegion]) {
        if !CLLocationManager.isRangingAvailable() {
            println("Couldn't turn on region ranging: Region ranging is not available for this device.")
            return
        }
        for beaconRegion: CLBeaconRegion in beaconRegions {
            self.locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    func stopRangingBeaconRegions (beaconRegions: [CLBeaconRegion]) {
        for beaconRegion: CLBeaconRegion in beaconRegions {
            self.locationManager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    func startMonitoringBeaconRegions (beaconRegions: [CLBeaconRegion]) {
        if !CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) {
            println("Couldn't turn on region monitoring: Region monitoring is not available for this device.")
            return
        }
        for beaconRegion: CLBeaconRegion in beaconRegions {
            self.locationManager.startMonitoringForRegion(beaconRegion)
        }
    }
    
    func stopMonitoringBeaconRegions (beaconRegions: [CLBeaconRegion]) {
        for beaconRegion: CLBeaconRegion in beaconRegions {
            self.locationManager.stopMonitoringForRegion(beaconRegion)
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
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kEnteredBeaconRegionNotificationName, object: self, userInfo: [kEnteredBeaconRegionNotificationUserInfoRegionKey: beaconRegion]))
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("did exit region: \(region)")
        if let beaconRegion = region as? CLBeaconRegion {
            if beaconRegion.major != nil && beaconRegion.minor != nil {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kExitedBeaconRegionNotificationName, object: self, userInfo: [kExitedBeaconRegionNotificationUserInfoRegionKey: beaconRegion]))
            }
        }
    }
}