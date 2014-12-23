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
    let storeName: String
    let modelName: String
    var options: NSDictionary?
    
    lazy var storeURL : NSURL = {
        return self.storeURLFromStoreName(self.storeName)
        }()
    
    var storeModel : NSManagedObjectModel? {
        for model in NSManagedObjectModel
            .modelVersionsForName(self.modelName) {
                if self.storeIsCompatibleWith(Model:model) {
                    println("Store \(self.storeURL) is compatible with model \(model.versionIdentifiers)")
                    return model
                }
        }
        
        println("Unable to determine storeModel")
        return nil
    }
    
    func isObjCDataExists() -> Bool {
        let storePaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let storePath = storePaths[0] as String
        return NSFileManager.defaultManager().fileExistsAtPath(storePath.stringByAppendingPathComponent(objcName + ".sqlite"))
    }
    
    lazy var currentModel: NSManagedObjectModel = {
        // Let core data tell us which model is the current model
        let modelURL = NSBundle.mainBundle().URLForResource(
            self.modelName, withExtension:"momd")
        let model = NSManagedObjectModel(contentsOfURL: modelURL!)
        return model!
        }()
    
    var stack: CoreDataStack {
        if isObjCDataExists() || !storeIsCompatibleWith(Model: currentModel) {
            performMigration()
        }
        
        return CoreDataStack(modelName: modelName, storeName: modelName, options: options)
    }
    
    init(storeNamed: String, modelNamed: String) {
        self.storeName = storeNamed
        self.modelName = modelNamed
    }
    
    func storeIsCompatibleWith(Model model: NSManagedObjectModel) -> Bool {
        let storeMetaData = metadataForStoreAtURL(storeURL)
        return model.isConfiguration(nil, compatibleWithStoreMetadata: storeMetaData)
    }
    
    func performMigration() {
        
        options = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: false]
        
        if isObjCDataExists() {
            let mappingModel = NSMappingModel(fromBundles: nil, forSourceModel: NSManagedObjectModel.objc(), destinationModel: NSManagedObjectModel.version4())
            migrateStoreAt(OldURL: storeURLFromStoreName(objcName), fromModel: NSManagedObjectModel.objc(), toNewURL: storeURLFromStoreName(swiftName), toModel: NSManagedObjectModel.version4(), mappingModel: mappingModel)
            performMigration()
        } else if let storeModel = storeModel {
            if storeModel.isVersion4() {
                let destinationModel = NSManagedObjectModel.version5()
                let mappingModel = NSMappingModel(fromBundles: nil, forSourceModel: storeModel, destinationModel: destinationModel)
                migrateStoreAt(OldURL: storeURL, fromModel: storeModel, toNewURL: storeURL, toModel: destinationModel, mappingModel: mappingModel)
                performMigration()
            } else if storeModel.isVersion5() {
                options = [NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true]
                let destinationModel = NSManagedObjectModel.version6()
                migrateStoreAt(OldURL: storeURL, fromModel: storeModel, toNewURL: storeURL, toModel: destinationModel, mappingModel: nil)
                performMigration()
            } else if storeModel.isVersion6() {
                let destinationModel = NSManagedObjectModel.version7()
                let mappingModel = NSMappingModel(fromBundles: nil, forSourceModel: storeModel, destinationModel: destinationModel)
                migrateStoreAt(OldURL: storeURL, fromModel: storeModel, toNewURL: storeURL, toModel: destinationModel, mappingModel: mappingModel)
            }
        }
    }
    
    func migrateStoreAt(OldURL oldStoreURL: NSURL, fromModel from: NSManagedObjectModel, toNewURL newStoreURL: NSURL, toModel to: NSManagedObjectModel, mappingModel: NSMappingModel? = nil) {
        let migrationManager = NSMigrationManager(sourceModel: from, destinationModel: to)
        
        var migrationMappingModel: NSMappingModel
        if let mappingModel = mappingModel {
            migrationMappingModel = mappingModel
        } else {
            var error: NSError?
            migrationMappingModel = NSMappingModel.inferredMappingModelForSourceModel(from, destinationModel: to, error: &error)!
        }
        
        let destinationURL = newStoreURL.URLByDeletingLastPathComponent
        let destinationName = newStoreURL.lastPathComponent! + "~" + "1"
        let destination = destinationURL!.URLByAppendingPathComponent(destinationName)
        
        println("From Model: \(from.versionIdentifiers)")
        println("To Model: \(to.versionIdentifiers)")
        println("Migrating store \(newStoreURL) to \(destination)")
        println("Mapping model: \(mappingModel)")
        
        var error: NSError?
        
        let success = migrationManager.migrateStoreFromURL(oldStoreURL, type: NSSQLiteStoreType, options: nil, withMappingModel: migrationMappingModel, toDestinationURL: destination, destinationType: NSSQLiteStoreType, destinationOptions: nil, error: &error)
        
        if success {
            println("Migration Completed Successfully")
            
            var error : NSError?
            let fileManager = NSFileManager.defaultManager()
            
            println("new url: \(newStoreURL)")
            fileManager.removeItemAtURL(oldStoreURL, error: &error)
            
            fileManager.moveItemAtURL(destination, toURL: newStoreURL, error:&error)
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
    
    class func version7() -> NSManagedObjectModel {
        return rememberModelNamed("remember 7")
    }
    
    func isVersion7() -> Bool {
        return self == self.dynamicType.version7()
    }
    
    class func version6() -> NSManagedObjectModel {
        return rememberModelNamed("remember 6")
    }
    
    func isVersion6() -> Bool {
        return self == self.dynamicType.version6()
    }
    
    class func version5() -> NSManagedObjectModel {
        return rememberModelNamed("remember 5")
    }
    
    func isVersion5() -> Bool {
        return self == self.dynamicType.version5()
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
    
    class func version3() -> NSManagedObjectModel {
        return rememberModelNamed("remember 3")
    }
    
    func isVersion3() -> Bool {
        return self == self.dynamicType.version3()
    }
    
    class func version2() -> NSManagedObjectModel {
        return rememberModelNamed("remember 2")
    }
    
    func isVersion2() -> Bool {
        return self == self.dynamicType.version2()
    }
    
    class func version1() -> NSManagedObjectModel {
        return rememberModelNamed("remember")
    }
    
    func isVersion1() -> Bool {
        return self == self.dynamicType.version1()
    }
}

func ==(firstModel: NSManagedObjectModel, otherModel: NSManagedObjectModel) -> Bool {
    let myEntities = firstModel.entitiesByName as NSDictionary
    let otherEntities = otherModel.entitiesByName as NSDictionary
    
    return myEntities.isEqualToDictionary(otherEntities)
}