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

    class func appGrayColor() -> UIColor {
        return UIColor(red: 197/255, green: 197/255, blue: 197/255, alpha: 1)
    }

    class func appGrayTextColor() -> UIColor {
        return UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
    }

    class func appGreenTextColor() -> UIColor {
        return UIColor(red: 62/255, green: 182/255, blue: 82/255, alpha: 1)
    }

    class func appBlackTextColor() -> UIColor {
        return UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}

extension CLLocationCoordinate2D {
    func printCoordinate() -> String {
        let lat = latitude.format("0.4")
        let long = longitude.format("0.4")
        return "\(lat), \(long)"
    }

    func distanceFromCoordinate(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distanceFromLocation(location2)
    }
}

extension NSDate {
    func dateStringOfLocalTimeZone() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return formatter.stringFromDate(self)
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
        return createdAt.timeIntervalSince1970.format(".0")
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
        newLocation.identifier = newLocation.createIndentifier()
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
}

extension UITableView {
    func removeFooterBorder () {
        tableFooterView = UIView(frame: CGRectZero)
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

extension String {
    func trimWhiteSpace() -> String {
        return self.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
    }
}

extension CAGradientLayer {
    
    func turquoiseColor() -> CAGradientLayer {
        let topColor = UIColor(red: (15/255.0), green: (118/255.0), blue: (128/255.0), alpha: 1)
        let bottomColor = UIColor(red: (84/255.0), green: (187/255.0), blue: (187/255.0), alpha: 1)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
}

extension UIView {
    func showAnimated() {
        alpha = 0.0
        transform = CGAffineTransformMakeScale(1.3, 1.3)
        
        UIView.animateWithDuration(0.4) {
            self.alpha = 1.0
            self.transform = CGAffineTransformIdentity
        }
    }
    
    func dismissAnimated() {
        alpha = 1.0
        transform = CGAffineTransformIdentity
        
        UIView.animateWithDuration(0.4) {
            self.alpha = 0.0
            self.transform = CGAffineTransformMakeScale(1.3, 1.3)
        }
    }
}

extension UIImage {
    func saveImageAsPNGWithName(name: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        let pathComponent = name + ".png"
        let path = documentsDirectory.stringByAppendingPathComponent(pathComponent)
        let data = UIImagePNGRepresentation(self)
        data.writeToFile(path, atomically: true)
    }
    
    class func loadPNGImageWithName(name: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        let pathComponent = name + ".png"
        let path = documentsDirectory.stringByAppendingPathComponent(pathComponent)
        return UIImage(contentsOfFile: path)
    }
}

extension Group {
    func createPrivateGroupInServer() {
        if let userId = NSUserDefaults.standardUserDefaults().valueForKey("userId") as? Int {
            let json: JSON = ["name": name, "creator_id": userId, "latitude": location.latitude, "longitude": location.longitude, "uuid": location.uuid, "major": location.major, "minor": location.minor]
            APIManager.postJSON(json, toURL: NSURL(string: kGroupPOSTURL)!, callback: { [weak self] (response, error, jsonObject) -> Void in
                if let id = jsonObject["id"].number {
                    self?.serverId = id
                    if let context = self?.managedObjectContext {
                        context.save(nil)
                    }
                }
            })
        }
    }
}