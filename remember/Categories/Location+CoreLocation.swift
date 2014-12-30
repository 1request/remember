//
//  Location+CoreLocation.swift
//  remember
//
//  Created by Joseph Cheung on 17/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

extension Location {
    func beaconRegion () -> CLBeaconRegion {
        let proximityUUID = NSUUID(UUIDString: uuid)
        let majorValue = major.unsignedShortValue
        let minorValue = minor.unsignedShortValue
        let region = CLBeaconRegion(proximityUUID: proximityUUID, major: majorValue, minor: minorValue, identifier: identifier)
        return region
    }
    
    func createIndentifier() {
        identifier = createdAt.timeIntervalSince1970.format(".0")
    }
    
    func circularRegion() -> CLCircularRegion {
        let center = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
        let region = CLCircularRegion(center: center, radius: 200, identifier: identifier)
        return region
    }
    
    func region() -> CLRegion {
        if uuid != "" {
            return beaconRegion()
        } else {
            return circularRegion()
        }
    }
    
    class func locationFromRegion (region: CLRegion, managedObjectContext: NSManagedObjectContext) -> Location? {
        let request = NSFetchRequest(entityName: "Location")
        
        let predicate = NSPredicate(format: "identifier == %@", region.identifier)
        
        request.predicate = predicate
        request.relationshipKeyPathsForPrefetching = ["messages"]
        var error: NSError?
        let locations = managedObjectContext.executeFetchRequest(request, error: &error)!
        
        if let e = error {
            println("fetch location from beacon region error: \(e.localizedDescription)")
            return nil
        }
        else {
            if !locations.isEmpty {
                return locations[0] as? Location
            }
            else {
                return nil
            }
        }
    }
    
    class func createBy(uuid: String, major: NSNumber, minor: NSNumber, context: NSManagedObjectContext) -> Location {
        let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: context) as Location
        newLocation.uuid = uuid
        newLocation.major = major
        newLocation.minor = minor
        newLocation.createdAt = NSDate()
        newLocation.updatedAt = newLocation.createdAt
        newLocation.createIndentifier()
        var error: NSError?
        if !context.save(&error) {
            println("cannot create new location: \(error)")
        }
        
        let e = AddLocationEvent(location: newLocation)
        Mixpanel.sharedInstance().track(kAddLocationEventTitle, properties: e.properties)
        return newLocation
    }
    
    class func findOrCreateBy(uuid: String, major: NSNumber, minor: NSNumber, context: NSManagedObjectContext) -> Location {
        
        let predicate = NSPredicate(format: "uuid == %@ AND major == %@ AND minor == %@", uuid, major, minor)
        
        let request = NSFetchRequest(entityName: "Location")
        request.predicate = predicate
        var error: NSError?
        let results = context.executeFetchRequest(request, error: &error) as [Location]
        if results.count > 0 {
            return results[0]
        } else {
            return createBy(uuid, major: major, minor: minor, context: context)
        }
    }
    
    class func monitorAllLocationsInContext(context: NSManagedObjectContext) {
        let request = NSFetchRequest(entityName: "Location")
        var error: NSError?
        
        if let locations = context.executeFetchRequest(request, error: &error) as? [Location] {
            let regions = locations.map() { (location) -> CLRegion in
                if location.uuid != "" {
                    return location.beaconRegion()
                } else {
                    return location.circularRegion()
                }
            }
            
            let beaconRegions = regions.filter() { (region) -> Bool in
                return region.isKindOfClass(CLBeaconRegion)
            }
            
            LocationManager.sharedInstance.startMonitoringRegions(regions)
            LocationManager.sharedInstance.startRangingBeaconRegions(beaconRegions as [CLBeaconRegion])
        }
    }
    
    class func locationFromCurrentCoordinate(context: NSManagedObjectContext) -> Location? {
        if let currentLocation = LocationManager.sharedInstance.currentLocation {
            let location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: context) as Location
            location.longitude = currentLocation.coordinate.longitude
            location.latitude = currentLocation.coordinate.latitude
            location.uuid = ""
            location.major = 0
            location.minor = 0
            location.createdAt = NSDate()
            location.updatedAt = location.createdAt
            location.createIndentifier()
            return location
        } else {
            return nil
        }
    }
}
