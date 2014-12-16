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
        if let currentUserId = User.currentUserId() {
            url = NSURL(string: kGroupsURL + "?user_id=\(currentUserId)")!
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
    
    class func updateAcceptedGroupsInContext(context: NSManagedObjectContext) {
        
        if let currentUserId = User.currentUserId() {
            let url = NSURL(string: kGroupsURL + "?user_id=\(currentUserId)&status=accepted")!
            
            APIManager.sendRequest(toURL: url, method: .GET, json: nil) { (response, error, jsonObject) -> Void in
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
                        group.location = location
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
            }
        }
    }
}