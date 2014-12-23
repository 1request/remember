//
//  GroupMigrationPolicy_v6_to_v7.swift
//  remember
//
//  Created by Joseph Cheung on 23/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData

class GroupMigrationPolicy_v6_to_v7: NSEntityMigrationPolicy {
    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager, error: NSErrorPointer) -> Bool {
        let newGroup = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: manager.destinationContext) as NSManagedObject
        
        for propertyMapping in mapping.attributeMappings
            as [NSPropertyMapping]! {
                let destinationName = propertyMapping.name
                if let valueExpression = propertyMapping.valueExpression {
                    let context: NSMutableDictionary = ["source": sInstance]
                    let destinationValue: AnyObject =
                    valueExpression.expressionValueWithObject(sInstance,
                        context: context)
                    newGroup.setValue(destinationValue,
                        forKey: destinationName!)
                }
        }
        let serverId = newGroup.valueForKey("serverId") as Int
        if serverId != 0 {
            let url = NSURL(string: kGroupsURL + "/\(serverId)")!
            
            let semaphore = dispatch_semaphore_create(0)
            
            APIManager.sendRequest(toURL: url, method: .GET, json: nil) { (response, error, jsonObject) -> Void in
                
                if let creatorId = jsonObject["creator_id"].number {
                    newGroup.setValue(creatorId, forKey: "creatorId")
                    println("creatorId: \(creatorId)")
                    dispatch_semaphore_signal(semaphore)
                }
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
        
        let sMessages = sInstance.valueForKey("messages") as NSSet
        let oldLocation = sInstance.valueForKey("location") as NSManagedObject
        let location = manager.destinationContext.objectWithID(oldLocation.objectID)
        newGroup.setValue(location, forKey: "location")
        
        for messageObj in sMessages {
            let message = messageObj as NSManagedObject
            let newMessage = manager.destinationContext.objectWithID(message.objectID)
            newMessage.setValue(newGroup, forKey: "group")
        }
        
        return true
    }
}
