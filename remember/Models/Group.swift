//
//  Group.swift
//  remember
//
//  Created by Joseph Cheung on 3/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreData

class Group: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var identifier: String
    @NSManaged var lastTriggerDate: NSDate
    @NSManaged var messagesCount: NSNumber
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var updatedAt: NSDate
    @NSManaged var location: Location
    @NSManaged var messages: NSSet

}
