//
//  LocationManager.swift
//  remember
//
//  Created by Joseph Cheung on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreLocation

let kEnteredRegionNotificationName = "enteredRegionNotification"
let kEnteredRegionNotificationUserInfoRegionKey = "region"
let kExitedRegionNotificationName = "exitedRegionNotification"
let kExitedRegionNotificationUserInfoRegionKey = "region"
let kRangedBeaconRegionNotificationName = "rangedBeaconNotification"
let kRangedBeaconRegionNotificationUserInfoBeaconsKey = "beacons"
let kGPSLocationUpdateNotificationName = "gpsLocationUpdateNotification"
let kGPSLocationUpdateNotificationUserInfoLocationKey = "location"
let kVisitsNotificationName = "visitNotification"
let kVisitsNotificationUserInfoVisitKey = "visit"

class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager = CLLocationManager()
    var locationAuthorized = false
    var currentLocation: CLLocation? = nil
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
            locationManager.startMonitoringForRegion(region)
            locationManager.requestStateForRegion(region)
        }
    }
    
    func stopMonitoringRegions (regions: [CLRegion]) {
        for region in regions {
            locationManager.stopMonitoringForRegion(region)
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
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        switch state {
        case .Inside:
            println("determined sate: inside region:\(region)")
        case .Outside:
            println("determined sate: outside region:\(region)")
        case .Unknown:
            println("determined sate: unknown region:\(region)")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        if !beacons.isEmpty {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kRangedBeaconRegionNotificationName, object: self, userInfo: [kRangedBeaconRegionNotificationUserInfoBeaconsKey: beacons]))
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("did enter region: \(region)")
        if let beaconRegion = region as? CLBeaconRegion {
            if beaconRegion.major != nil && beaconRegion.minor != nil {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kEnteredRegionNotificationName, object: self, userInfo: [kEnteredRegionNotificationUserInfoRegionKey: beaconRegion as CLRegion]))
                if let location = currentLocation {
                    let e = BeaconRegionEvent(event: .Enter, region: beaconRegion, scene: location)
                    NSUserDefaults.standardUserDefaults().setValue(e.properties, forKey: kEnteredBeaconEventTitle)
                    Mixpanel.sharedInstance().track(e.title, properties: e.properties)
                }
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kEnteredRegionNotificationName, object: self, userInfo: [kEnteredRegionNotificationUserInfoRegionKey: region as CLRegion]))
            if let location = currentLocation {
                let e = GeographicRegionEvent(eventType: .Enter, region: region as CLCircularRegion, scene: location)
                NSUserDefaults.standardUserDefaults().setValue(e.properties, forKey: kEnteredGeoEventTitle)
                Mixpanel.sharedInstance().track(e.title, properties: e.properties)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("did exit region: \(region)")
        if let beaconRegion = region as? CLBeaconRegion {
            if beaconRegion.major != nil && beaconRegion.minor != nil {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kExitedRegionNotificationName, object: self, userInfo: [kExitedRegionNotificationUserInfoRegionKey: beaconRegion]))
                if let location = currentLocation {
                    let e = BeaconRegionEvent(event: .Exit, region: beaconRegion, scene: location)
                    NSUserDefaults.standardUserDefaults().setValue(e.properties, forKey: kExitedBeaconEventTitle)
                    Mixpanel.sharedInstance().track(e.title, properties: e.properties)
                }
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kExitedRegionNotificationName, object: self, userInfo: [kExitedRegionNotificationUserInfoRegionKey: region as CLRegion]))
            if let location = currentLocation {
                let e = GeographicRegionEvent(eventType: .Exit, region: region as CLCircularRegion, scene: location)
                NSUserDefaults.standardUserDefaults().setValue(e.properties, forKey: kExitedGeoEventTitle)
                Mixpanel.sharedInstance().track(e.title, properties: e.properties)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            let notification = NSNotification(name: kGPSLocationUpdateNotificationName, object: self, userInfo: [kGPSLocationUpdateNotificationUserInfoLocationKey: location])
            NSNotificationCenter.defaultCenter().postNotification(notification)
            currentLocation = location
            println("(\(NSDate().dateStringOfLocalTimeZone())) updated gps coordinate: (\(location.coordinate.printCoordinate())) | distance filter: \(locationManager.distanceFilter) | desired accuracy: \(locationManager.desiredAccuracy)")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
        let notification = NSNotification(name: kVisitsNotificationName, object: self, userInfo: [kVisitsNotificationUserInfoVisitKey: visit])
        
        if let location = currentLocation {
            let e = VisitEvent(visit: visit, scene: location)
            NSUserDefaults.standardUserDefaults().setValue(e.properties, forKey: "Visit")
            Mixpanel.sharedInstance().track(e.title, properties: e.properties)
        }
    }
}