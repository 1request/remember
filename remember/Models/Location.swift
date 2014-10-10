//
//  Location.swift
//  remember
//
//  Created by Joseph Cheung on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var uuid: String
    @NSManaged var major: NSNumber
    @NSManaged var minor: NSNumber
    @NSManaged var name: String
    @NSManaged var lastTriggerDate: NSDate
    @NSManaged var messageCount: NSNumber
    @NSManaged var messages: NSSet

}
