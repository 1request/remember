//
//  LocationMigrationPolicy_v4_to_v5.swift
//  remember
//
//  Created by Joseph Cheung on 5/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData

class LocationMigrationPolicy_v4_to_v5: NSEntityMigrationPolicy {
    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager, error: NSErrorPointer) -> Bool {
        let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: manager.destinationContext) as NSManagedObject
        
        for propertyMapping in mapping.attributeMappings
            as [NSPropertyMapping]! {
                let destinationName = propertyMapping.name
                if let valueExpression = propertyMapping.valueExpression {
                    let context: NSMutableDictionary = ["source": sInstance]
                    let destinationValue: AnyObject =
                    valueExpression.expressionValueWithObject(sInstance,
                        context: context)
                    newLocation.setValue(destinationValue,
                        forKey: destinationName!)
                }
        }
        
        let request = NSFetchRequest(entityName: "Group")
        let predicate = NSPredicate(format: "identifier == %@", sInstance.valueForKey("identifier") as String)
        
        request.predicate = predicate
        
        var error: NSError?
        let fetchedGroups = manager.destinationContext.executeFetchRequest(request, error: &error)
        
        if fetchedGroups?.count > 0 {
            if let newGroups = fetchedGroups as? [NSManagedObject] {
                
                var groups = NSMutableSet()
                for group in newGroups {
                    groups.addObject(group)
                }
                
                newLocation.setValue(groups, forKey: "groups")
            }
        }
        
        return true
    }
}
