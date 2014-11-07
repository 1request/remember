//
//  Location.swift
//  remember
//
//  Created by Joseph Cheung on 7/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var lastTriggerDate: NSDate
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var major: NSNumber
    @NSManaged var messageCount: NSNumber
    @NSManaged var minor: NSNumber
    @NSManaged var name: String
    @NSManaged var updatedAt: NSDate
    @NSManaged var uuid: String
    @NSManaged var identifier: String
    @NSManaged var messages: NSSet

}
