//
//  ObjCToSwiftMigrationPolicy.swift
//  remember
//
//  Created by Joseph Cheung on 18/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//
import CoreData
import UIKit

class ObjCToSwiftMigrationPolicy: NSEntityMigrationPolicy {

    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager, error: NSErrorPointer) -> Bool {
        let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: manager.destinationContext) as NSManagedObject
        
        for propertyMapping in mapping.attributeMappings as [NSPropertyMapping]! {
            let destinationName = propertyMapping.name
            if let valueExpression = propertyMapping.valueExpression {
                let context: NSMutableDictionary = ["source": sInstance]
                let destinationValue: AnyObject = valueExpression.expressionValueWithObject(sInstance, context: context)
                newLocation.setValue(destinationValue, forKey: destinationName!)
            }
        }
        
        let name = sInstance.valueForKey("name") as NSString
        let createdAt = sInstance.valueForKey("createdAt") as NSDate
        let identifier = name + "-" + createdAt.timeIntervalSince1970.format(".0")
        
        newLocation.setValue(identifier, forKey: "identifier")
        newLocation.setValue(0, forKey: "longitude")
        newLocation.setValue(0, forKey: "latitude")
        
        manager.associateSourceInstance(sInstance, withDestinationInstance: newLocation, forEntityMapping: mapping)
        
        return true
    }
}
