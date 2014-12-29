//
//  Group+API.swift
//  remember
//
//  Created by Joseph Cheung on 16/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreData

extension Group {
    
    class func join(groupId: Int, callback: (() -> Void)?) {
        let url = NSURL(string: kMembershipsURL)!
        let json: JSON = ["group_id": groupId, "user_id": User.currentUserId()!]
        APIManager.sendRequest(toURL: url, method: .POST, json: json) { (response, error, jsonObject) -> Void in
            if let cb = callback {
                dispatch_async(dispatch_get_main_queue()) {
                    cb()
                }
            }
        }
    }
    
    class func fetchGroupsFromServer(callback: (groups: [[String: AnyObject]]) -> Void) {
        var url = NSURL(string: kGroupsURL)!
        
        if let coordinate = LocationManager.sharedInstance.currentLocation?.coordinate {
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            if let currentUserId = User.currentUserId() {
                url = NSURL(string: kGroupsURL + "?user_id=\(currentUserId)&lat=\(latitude)&lng=\(longitude)")!
            } else {
                url = NSURL(string: kGroupsURL + "?lat=\(latitude)&lng=\(longitude)")!
            }
        }
        
        APIManager.sendRequest(toURL: url, method: .GET, json: nil) { (response, error, jsonObject) -> Void in
            var groups = [[String: AnyObject]]()
            for (index: String, subJson: JSON) in jsonObject {
                var dict = [String: AnyObject]()
                dict["name"] = subJson["name"].stringValue
                dict["id"] = subJson["id"].intValue
                dict["status"] = subJson["status"].stringValue
                dict["longitude"] = subJson["location"]["longitude"].doubleValue
                dict["latitude"] = subJson["location"]["latitude"].doubleValue
                dict["url"] = subJson["creator_profile_url"].stringValue
                if User.isRegistered() {
                    if User.currentUserId() != subJson["creator_id"].number && subJson["status"].stringValue != "accepted" {
                        groups.append(dict)
                    }
                } else {
                    groups.append(dict)
                }
            }
            callback(groups: groups)
        }
    }
    
    class func updateAcceptedGroupsInContext(context: NSManagedObjectContext, completionHandler:((UIBackgroundFetchResult) -> Void)?) {
        
        if let currentUserId = User.currentUserId() {
            let url = NSURL(string: kGroupsURL + "?user_id=\(currentUserId)&status=accepted")!
            
            APIManager.sendRequest(toURL: url, method: .GET, json: nil) { (response, error, jsonObject) -> Void in
                if error != nil {
                    if let handler = completionHandler {
                        handler(.Failed)
                    }
                } else {
                    let ids = map(jsonObject) { (index, json) -> Int in
                        return json["id"].intValue
                    }
                    
                    let request = NSFetchRequest(entityName: "Group")
                    request.propertiesToFetch = ["serverId"]
                    let predicate = NSPredicate(format: "serverId != 0")
                    request.predicate = predicate
                    request.resultType = NSFetchRequestResultType.DictionaryResultType
                    
                    let fetchResult = context.executeFetchRequest(request, error: nil)
                    
                    var localGroupIds = [Int]()
                    if let serverIds = fetchResult {
                        localGroupIds = serverIds.map() {(dict) -> Int in
                            return dict["serverId"] as Int
                        }
                    }
                    
                    let missingGroups = ids.filter() { (id) -> Bool in
                        return !contains(localGroupIds, id)
                    }
                    
                    if missingGroups.count == 0 {
                        if let handler = completionHandler {
                            handler(.NoData)
                        }
                        return
                    }
                    
                    let groupsToBeAdded = filter(jsonObject, { (index, json) -> Bool in
                        return contains(missingGroups, json["id"].intValue)
                    })
                    
                    for (index, json) in groupsToBeAdded {
                        let group = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: context) as Group
                        group.serverId = json["id"].intValue
                        group.name = json["name"].stringValue
                        group.createdAt = NSDate()
                        group.updatedAt = group.createdAt
                        group.type = "private"
                        if json["location"]["uuid"].stringValue != "" {
                            let location = Location.findOrCreateBy(json["location"]["uuid"].stringValue, major: json["location"]["major"].intValue, minor: json["location"]["minor"].intValue, context: context)
                            location.latitude = json["location"]["latitude"].floatValue
                            location.longitude = json["location"]["longitude"].floatValue
                            group.location = location
                            LocationManager.sharedInstance.startMonitoringRegions([location.beaconRegion()])
                            LocationManager.sharedInstance.startRangingBeaconRegions([location.beaconRegion()])
                        } else {
                            let location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: context) as Location
                            location.latitude = json["location"]["latitude"].floatValue
                            location.longitude = json["location"]["longitude"].floatValue
                            location.uuid = ""
                            location.createIndentifier()
                            location.createdAt = NSDate()
                            location.updatedAt = location.createdAt
                            group.location = location
                        }
                        
                        context.save(nil)
                    }
                    
                    if let handler = completionHandler {
                        handler(.NewData)
                    }
                }
            }
        }
    }
    
    func createPrivateGroupInServer(callback: (() -> Void)?) {
        if let userId = NSUserDefaults.standardUserDefaults().valueForKey("userId") as? Int {
            let json: JSON = ["name": name, "creator_id": userId, "latitude": location.latitude, "longitude": location.longitude, "uuid": location.uuid, "major": location.major, "minor": location.minor]
            APIManager.sendRequest(toURL: NSURL(string: kGroupsURL)!, method: .POST, json: json) { [weak self] (response, error, jsonObject) -> Void in
                if let id = jsonObject["id"].number {
                    self?.serverId = id
                    if let context = self?.managedObjectContext {
                        context.save(nil)
                    }
                    if let cb = callback {
                        dispatch_async(dispatch_get_main_queue()) {
                            cb()
                        }
                    }
                }
            }
        }
    }
    
    func fetchMessages(callback: () -> Void) {
        if serverId != 0 {
            if let userId = User.currentUserId() {
                let url = NSURL(string: kAudiosURL + "?group_id=\(serverId)")!
                APIManager.sendRequest(toURL: url, method: .GET, json: nil) { [weak self](response, error, jsonObject) -> Void in
                    let otherUsersMessages = filter(jsonObject) { (index, json) -> Bool in
                        json["user_id"].intValue != userId
                    }
                    
                    let request = NSFetchRequest(entityName: "Message")
                    request.resultType = .DictionaryResultType
                    request.propertiesToFetch = ["serverId"]
                    let predicate = NSPredicate(format: "serverId != 0")
                    request.predicate = predicate
                    
                    var localMessageIds = [Int]()
                    
                    if let weakself = self {
                        if let fetchResult = weakself.managedObjectContext?.executeFetchRequest(request, error: nil) {
                            localMessageIds = fetchResult.map({ (result) -> Int in
                                let dict = result as [NSObject: AnyObject]
                                return dict["serverId"] as Int
                            })
                        }
                        let missingMessages = otherUsersMessages.filter() { (index, json) -> Bool in
                            return !contains(localMessageIds, json["id"].intValue)
                        }

                        for (index, messageJson) in missingMessages {
                            let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: weakself.managedObjectContext!) as Message
                            message.userId = messageJson["user_id"].intValue
                            User.downloadProfileImageForUserId(Int(message.userId))
                            message.serverId = messageJson["id"].intValue
                            let formatter = ISO8601DateFormatter()
                            let date = formatter.dateFromString(messageJson["created_at"].stringValue)
                            message.createdAt = date
                            message.updatedAt = date
                            message.isRead = false
                            weakself.messagesCount = NSNumber(integer: (weakself.messagesCount.integerValue + 1))
                            message.name = String(format: RECORD_NAME, weakself.messagesCount)
                            let url = NSURL(string: kAPIUrl + messageJson["audioclip_url"].stringValue)!

                            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
                            let session = NSURLSession(configuration: sessionConfig)
                            let task = session.downloadTaskWithURL(url, completionHandler: { (location, response, error) -> Void in
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    if let data = NSData(contentsOfURL: location) {
                                        let filePathString = kApplicationPath + "/" + message.createdAt.timeIntervalSince1970.format(".0") + ".m4a"
                                        data.writeToFile(filePathString, atomically: true)
                                    }
                                })
                            })
                            task.resume()
                            message.group = weakself
                            weakself.managedObjectContext?.save(nil)
                        }
                        callback()
                    }
                }
            }
        }
    }
    
    func fetchApplyingMemberships(callback: (members: [JSON]) -> Void) {
        let url = NSURL(string: kGroupsURL + "/\(serverId)")!
        APIManager.sendRequest(toURL: url, method: .GET, json: nil) { (response, error, jsonObject) -> Void in
            let applyingMembers = jsonObject["applying_members"].arrayValue
            callback(members: applyingMembers)
        }
    }
}