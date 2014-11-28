//
//  DataMigrationManager.swift
//  remember
//
//  Created by Joseph Cheung on 18/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreData

class DataMigrationManager {
    let objcName = "remember_objc"
    let swiftName = "remember"
    var options: NSDictionary?
    
    func isObjCDataExists() -> Bool {
        let storePaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let storePath = storePaths[0] as String
        return NSFileManager.defaultManager().fileExistsAtPath(storePath.stringByAppendingPathComponent(objcName + ".sqlite"))
    }
    
    init() {
    }
    
    var stack: CoreDataStack {
        if isObjCDataExists() {
            performMigration()
        } else {
            options = [NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true]
        }
        
        return CoreDataStack(modelName: swiftName, storeName: swiftName, options: options)
    }
    
    func performMigration() {
        let migrationManager = NSMigrationManager(sourceModel: NSManagedObjectModel.objc(), destinationModel: NSManagedObjectModel.version4())
        
        options = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: false]
        
        let mappingModel = NSMappingModel(fromBundles: nil, forSourceModel: NSManagedObjectModel.objc(), destinationModel: NSManagedObjectModel.version4())
        
        let storeURL = storeURLFromStoreName(objcName)
        let newURL = storeURLFromStoreName(swiftName)
        let destinationURL = storeURLFromStoreName(swiftName).URLByDeletingLastPathComponent
        let destinationName = storeURLFromStoreName(swiftName).lastPathComponent + "~" + "1"
        let destination = destinationURL!.URLByAppendingPathComponent(destinationName)
        
        println("From Model: \(NSManagedObjectModel.objc().versionIdentifiers)")
        println("To Model: \(NSManagedObjectModel.version4().versionIdentifiers)")
        println("Migrating store \(storeURL) to \(destination)")
        println("Mapping model: \(mappingModel)")
        
        var error: NSError?
        
        let success = migrationManager.migrateStoreFromURL(storeURL, type: NSSQLiteStoreType, options: nil, withMappingModel: mappingModel, toDestinationURL: destination, destinationType: NSSQLiteStoreType, destinationOptions: nil, error: &error)
        
        if success {
            println("Migration Completed Successfully")
            
            var error : NSError?
            let fileManager = NSFileManager.defaultManager()
            
            
            println("new url: \(newURL)")
            fileManager.removeItemAtURL(storeURL, error: &error)
            
            fileManager.moveItemAtURL(destination, toURL: newURL, error:&error)
        } else {
            NSLog("Error migrating \(error)")
        }
        
    }
    
    func storeURLFromStoreName(name: String) -> NSURL {
        let storePaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let storePath = storePaths[0] as String
        return NSURL.fileURLWithPath(storePath.stringByAppendingPathComponent(name + ".sqlite"))!
    }
    
    func storeWithName(name: String, IsCompatibleWithModel model:NSManagedObjectModel) -> Bool {
            let storeMetadata = metadataForStoreAtURL(storeURLFromStoreName(name))
            
            return model.isConfiguration(nil,
                compatibleWithStoreMetadata:storeMetadata)
    }
    
    func metadataForStoreAtURL(storeURL:NSURL) -> NSDictionary! {
        var error : NSError?
        let metadata = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
            NSSQLiteStoreType, URL: storeURL, error: &error)
        if metadata == nil {
            println(error)
        }
        return metadata
    }
}

extension NSManagedObjectModel {
    class func modelVersionsForName(name: String) -> [NSManagedObjectModel] {
            let urls = NSBundle.mainBundle().URLsForResourcesWithExtension("mom", subdirectory:"\(name).momd") as [NSURL]
            return urls.map { url in NSManagedObjectModel(contentsOfURL:url)! }
    }
    
    class func rememberModelNamed(name:String) -> NSManagedObjectModel {
        let modelURL = NSBundle.mainBundle().URLForResource(name, withExtension:"mom", subdirectory:"remember.momd")
        return NSManagedObjectModel(contentsOfURL:modelURL!)!
    }
    
    class func version4() -> NSManagedObjectModel {
        return rememberModelNamed("remember 4")
    }
    
    func isVersion4() -> Bool {
        return self == self.dynamicType.version4()
    }
    
    class func objc() -> NSManagedObjectModel {
        return rememberModelNamed("remember-objc")
    }
    
    func isObjc() -> Bool {
        return self == self.dynamicType.objc()
    }
}