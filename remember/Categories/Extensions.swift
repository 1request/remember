//
//  Extensions.swift
//  remember
//
//  Created by Joseph Cheung on 10/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

extension UIColor {
    class func appBlueColor() -> UIColor {
        return UIColor(red: 0, green: 145/255, blue: 1, alpha: 1)
    }
    
    class func appGreyColor() -> UIColor {
        return UIColor(red: 197/255, green: 197/255, blue: 197/255, alpha: 1)
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}

extension Location {
    func beaconRegion () -> CLBeaconRegion {
        let proximityUUID = NSUUID(UUIDString: uuid)
        let majorValue = major.unsignedShortValue
        let minorValue = minor.unsignedShortValue
        let region = CLBeaconRegion(proximityUUID: proximityUUID, major: majorValue, minor: minorValue, identifier: identifier)
        return region
    }
    
    func createIndentifier() -> String {
        return "\(name)-" + createdAt.timeIntervalSince1970.format(".0")
    }
    
    func circularRegion() -> CLCircularRegion {
        let center = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
        let region = CLCircularRegion(center: center, radius: kCLLocationAccuracyNearestTenMeters, identifier: identifier)
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
}

extension UITableView {
    func removeFooterBorder () {
        self.tableFooterView = UIView(frame: CGRectZero)
    }
}