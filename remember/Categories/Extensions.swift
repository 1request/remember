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
        let proximityUUID = NSUUID(UUIDString: self.uuid)
        let major = self.major.unsignedShortValue
        let minor = self.minor.unsignedShortValue
        let identifier = "\(self.name)-" + self.createdAt.timeIntervalSince1970.format(".0")
        let region = CLBeaconRegion(proximityUUID: proximityUUID, major: major, minor: minor, identifier: identifier)
        return region
    }
    
    class func locationFromBeaconRegion (beaconRegion: CLBeaconRegion, managedObjectContext: NSManagedObjectContext) -> Location? {
        let request = NSFetchRequest(entityName: "Location")
        let predicate = NSPredicate(format: "uuid == %@ AND major == %@ AND minor == %@", beaconRegion.proximityUUID.UUIDString, beaconRegion.major, beaconRegion.minor)
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
