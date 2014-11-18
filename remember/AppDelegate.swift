//
//  AppDelegate.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics
import CoreLocation
import AVFoundation

let kAlertLocationNotificationName = "kAlertLocationNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Crashlytics.startWithAPIKey("a73df0ceadf9f0995f97da85f3a3ca791c3e0de1")
        
        let mixpanel = Mixpanel.sharedInstanceWithToken("3b27052c32a6e7426f27e17b0a1f2e7e")
        mixpanel.track("Swift")
        if UIDevice.currentDevice().model != "iPhone Simulator" {
            mixpanel.identify(UIDevice.currentDevice().identifierForVendor.UUIDString)
            mixpanel.people.set(["language": "Swift"])
        }
        
        if let navigationController = window?.rootViewController as? NavigationController {
            if let homeViewController = navigationController.topViewController as? HomeViewController {
                homeViewController.managedObjectContext = managedObjectContext!
            }
        }
        monitorLocations()
        LocationManager.sharedInstance.startUpdatingLocation()
        
        if LocationManager.sharedInstance.locationManager.respondsToSelector("startMonitoringVisits") {
            LocationManager.sharedInstance.locationManager.startMonitoringVisits()
        }
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        clearNotifications()
        let state = application.applicationState
        if state == UIApplicationState.Active {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            AudioServicesPlaySystemSound(1007)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        clearNotifications()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "request.remember" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("remember", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("remember.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true], error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}

extension AppDelegate {
    func monitorLocations () {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationEvent:", name: kEnteredRegionNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationEvent:", name: kExitedRegionNotificationName, object: nil)
    }
    
    func locationFromNotification(notification: NSNotification) -> Location? {
        if let dict = notification.userInfo as? Dictionary<String, CLRegion> {
            let regionObject = dict["region"]!
            if let location = Location.locationFromRegion(regionObject, managedObjectContext: managedObjectContext!) {
                return location
            }
        }
        return nil
    }
    
    func  handleLocationEvent(notification: NSNotification) {
        if let location = locationFromNotification(notification) {
            let previousTriggerDate = location.lastTriggerDate.timeIntervalSince1970
            let currentTime = NSDate().timeIntervalSince1970
            let predicate = NSPredicate(format: "isRead == 0")
            let unreadMessages = location.messages.filteredSetUsingPredicate(predicate!)
//            if unreadMessages.count > 0 && currentTime - previousTriggerDate > 3600 {
            if unreadMessages.count > 0 {
                var title = ""
                var message = ""
                location.lastTriggerDate = NSDate()
                managedObjectContext?.save(nil)
                
                NSUserDefaults.standardUserDefaults().setValue(location.identifier, forKey: "location")
                
                if notification.name == kEnteredRegionNotificationName {
                    title = "New message from \(location.name)"
                    message = "\(location.name) got \(unreadMessages.count) new notification" + (unreadMessages.count > 1 ? "s" : "")
                    NSUserDefaults.standardUserDefaults().setValue(1, forKey: "Enter")
                } else if notification.name == kExitedRegionNotificationName {
                    title = "New message from \(location.name)"
                    message = "You got \(unreadMessages.count) new notification" + (unreadMessages.count > 1 ? "s" : "") + " before you leave \(location.name)"
                    NSUserDefaults.standardUserDefaults().setValue(0, forKey: "Enter")
                }
                
                var userInfo = ["title": title, "message": message]
                sendLocalNotificationWithMessage(message)
                
                NSNotificationCenter.defaultCenter().postNotificationName(kAlertLocationNotificationName, object: self, userInfo: userInfo)
            }
        }
    }
    
    func sendLocalNotificationWithMessage (message: String) {
        let notification = UILocalNotification()
        notification.alertBody = message
        notification.alertAction = "View Details"
        notification.soundName = UILocalNotificationDefaultSoundName
        let request = NSFetchRequest(entityName: "Message")
        request.predicate = NSPredicate(format: "isRead == 0")
        let count = managedObjectContext?.countForFetchRequest(request, error: nil)
        if let cnt = count {
            notification.applicationIconBadgeNumber = cnt
        }
        
        if notification.respondsToSelector("regionTriggersOnce") {
            notification.regionTriggersOnce = true
        }
        
        if UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:") {
            let types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
        
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func clearNotifications () {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
}
