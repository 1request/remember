//
//  LocationToGroupMigrationPolicy.swift
//  remember
//
//  Created by Joseph Cheung on 2/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData

class LocationToGroupMigrationPolicy: NSEntityMigrationPolicy {
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
        
        let messages = sInstance.valueForKey("messages") as NSSet
        
        for messageObj in messages {
            let message = messageObj as NSManagedObject
            let newMessage = manager.destinationContext.objectWithID(message.objectID)
            let groupMessages = newGroup.valueForKey("messages") as NSMutableSet
            groupMessages.addObject(newMessage)
            newGroup.setValue(groupMessages, forKey: "messages")
        }
        
        let location = manager.destinationContext.objectWithID(sInstance.objectID)
        
        newGroup.setValue(location, forKey: "location")
        
        manager.associateSourceInstance(sInstance,
            withDestinationInstance: newGroup,
            forEntityMapping: mapping)
        
        return true
    }
}
