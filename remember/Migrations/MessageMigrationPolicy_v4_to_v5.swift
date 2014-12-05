//
//  MessageMigrationPolicy_v4_to_v5.swift
//  remember
//
//  Created by Joseph Cheung on 5/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData

class MessageMigrationPolicy_v4_to_v5: NSEntityMigrationPolicy {
    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager, error: NSErrorPointer) -> Bool {
        let newMessage = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: manager.destinationContext) as NSManagedObject
        
        for propertyMapping in mapping.attributeMappings
            as [NSPropertyMapping]! {
                let destinationName = propertyMapping.name
                if let valueExpression = propertyMapping.valueExpression {
                    let context: NSMutableDictionary = ["source": sInstance]
                    let destinationValue: AnyObject =
                    valueExpression.expressionValueWithObject(sInstance,
                        context: context)
                    newMessage.setValue(destinationValue,
                        forKey: destinationName!)
                }
        }
        
        let request = NSFetchRequest(entityName: "Group")
        let oldLocation = sInstance.valueForKey("location") as NSManagedObject
        let predicate = NSPredicate(format: "identifier == %@", oldLocation.valueForKey("identifier") as String)
        
        request.predicate = predicate
        
        var error: NSError?
        let fetchedGroups = manager.destinationContext.executeFetchRequest(request, error: &error)

        if fetchedGroups?.count == 1 {
            if let newGroup = fetchedGroups?[0] as? NSManagedObject {
                newMessage.setValue(newGroup, forKey: "group")
            }
        }
        
        return true
    }
}
