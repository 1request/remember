//
//  Message.swift
//  remember
//
//  Created by Joseph Cheung on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreData

class Message: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var isRead: NSNumber
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var location: Location

}
