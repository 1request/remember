//
//  Group+Seed.swift
//  remember
//
//  Created by Joseph Cheung on 29/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreData

extension Group {
    class func generateSeedData(context: NSManagedObjectContext) {
        let OFFICE = NSLocalizedString("OFFICE", comment: "office group name text")
        let HOME = NSLocalizedString("HOME", comment: "office group name text")
        
        let officeGroup = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: context) as Group
        let homeGroup = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: context) as Group
        officeGroup.name = OFFICE
        homeGroup.name = HOME
        
        context.save(nil)
        
        NSUserDefaults.standardUserDefaults().setValue(true, forKey: "firstInstallation")
    }
}