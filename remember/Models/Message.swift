//
//  Message.swift
//  remember
//
//  Created by Joseph Cheung on 7/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreData

class Message: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var isRead: NSNumber
    @NSManaged var name: String
    @NSManaged var updatedAt: NSDate
    @NSManaged var location: Location

}
