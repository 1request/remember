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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let NEW_MEMBER = NSLocalizedString("NEW_MEMBER", comment: "alert title for approving / rejecting new member")
    
    lazy var managedObjectContext : NSManagedObjectContext = {
        let manager = DataMigrationManager(storeNamed: "remember", modelNamed: "remember")
        return manager.stack.context
        }()
    
    override class func initialize() -> Void {
        iRate.sharedInstance().onlyPromptIfLatestVersion = false
        iRate.sharedInstance().daysUntilPrompt = 3
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Crashlytics.startWithAPIKey("a73df0ceadf9f0995f97da85f3a3ca791c3e0de1")
        
        let mixpanel = Mixpanel.sharedInstanceWithToken("3b27052c32a6e7426f27e17b0a1f2e7e")
        
#if !DEBUG
        if (NSBundle.mainBundle().bundleIdentifier! == "request.remember") {
            mixpanel.track("AppStore")
        } else {
            mixpanel.track("Enterprise")
        }
        mixpanel.identify(UIDevice.currentDevice().identifierForVendor.UUIDString)
#else
            mixpanel.track("Debug")
            mixpanel.identify("Debug")
#endif
        mixpanel.people.set(["language": "Swift", "name": UIDevice.currentDevice().name])
        
        if NSUserDefaults.standardUserDefaults().valueForKey("firstInstallation") == nil {
            Group.generateSeedData(managedObjectContext)
        }
        
        if let navigationController = window?.rootViewController as? NavigationController {
            if let homeViewController = navigationController.topViewController as? HomeViewController {
                homeViewController.managedObjectContext = managedObjectContext
            }
        }
        monitorLocations()
        LocationManager.sharedInstance.startUpdatingLocation()
        
        if LocationManager.sharedInstance.locationManager.respondsToSelector("startMonitoringVisits") {
            LocationManager.sharedInstance.locationManager.startMonitoringVisits()
        }
        
        registerNotification()
        
        if let options = launchOptions {
            if options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
                self.application(application, didReceiveRemoteNotification: options[UIApplicationLaunchOptionsRemoteNotificationKey] as [NSObject: AnyObject])
            }
        }
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.description.stringByReplacingOccurrencesOfString(" ", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
        Mixpanel.sharedInstance().people.addPushDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("register remote notification error: \(error)")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        clearNotifications()
        let state = application.applicationState
        if state == UIApplicationState.Active {
            playAlert()
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let message = userInfo["aps"] as [NSObject: AnyObject]
        if let approveMemberDetails = userInfo["approve_member"] as? [NSObject: AnyObject] {
            approveMemeberWithUserInfo(userInfo)
        } else if let newAudio = userInfo["new_audio"] as? [NSObject: AnyObject] {
            let state = application.applicationState
            if state == UIApplicationState.Active {
                playAlert()
            }
            let groupId = newAudio["group_id"] as Int
            fetchNewAudioWithGroupId(groupId)
        }
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Group.updateAcceptedGroupsInContext(managedObjectContext, completionHandler: completionHandler)
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
    }
}
extension AppDelegate {
    func monitorLocations () {
        LocationManager.sharedInstance.stopMonitoringExistingRegions()
        Location.monitorAllLocationsInContext(managedObjectContext)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationEvent:", name: kEnteredRegionNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationEvent:", name: kExitedRegionNotificationName, object: nil)
    }
    
    func locationFromNotification(notification: NSNotification) -> Location? {
        if let dict = notification.userInfo as? [String: CLRegion] {
            let regionObject = dict["region"]!
            if let location = Location.locationFromRegion(regionObject, managedObjectContext: managedObjectContext) {
                return location
            }
        }
        return nil
    }
    
    func  handleLocationEvent(notification: NSNotification) {
        if let location = locationFromNotification(notification) {
            let currentTime = NSDate().timeIntervalSince1970
            let predicate = NSPredicate(format: "isRead == 0")
            for groupObject in location.groups {
                let group = groupObject as Group
                group.fetchMessages({ [weak self] () -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let previousTriggerDate = group.lastTriggerDate.timeIntervalSince1970
                        let unreadMessages = group.messages.filteredSetUsingPredicate(predicate!)
                        if unreadMessages.count > 0 && currentTime - previousTriggerDate > 3600 {
                            var title = ""
                            var message = ""
                            group.lastTriggerDate = NSDate()
                            group.managedObjectContext?.save(nil)
                            
                            if notification.name == kEnteredRegionNotificationName {
                                title = "New message from \(group.name)"
                                message = "\(group.name) got \(unreadMessages.count) new notification" + (unreadMessages.count > 1 ? "s" : "")
                                NSUserDefaults.standardUserDefaults().setValue(1, forKey: "Enter")
                            } else if notification.name == kExitedRegionNotificationName {
                                title = "New message from \(group.name)"
                                message = "You got \(unreadMessages.count) new notification" + (unreadMessages.count > 1 ? "s" : "") + " before you leave \(group.name)"
                                NSUserDefaults.standardUserDefaults().setValue(0, forKey: "Enter")
                            }
                            
                            var userInfo = ["title": title, "message": message]
                            self?.sendLocalNotificationWithMessage(message)
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(kAlertLocationNotificationName, object: self, userInfo: userInfo)
                        }
                    })
                })
            }
        }
    }
    
    func registerNotification() {
        let application = UIApplication.sharedApplication()
        let types = (UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert)
        let remoteTypes = (UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert)
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        if application.respondsToSelector("registerForRemoteNotificationTypes") {
            application.registerForRemoteNotificationTypes(.Badge | .Sound | .Alert)
        }
    }
    
    func sendLocalNotificationWithMessage (message: String) {
        let notification = UILocalNotification()
        notification.alertBody = message
        notification.alertAction = "View Details"
        notification.soundName = UILocalNotificationDefaultSoundName
        let request = NSFetchRequest(entityName: "Message")
        request.predicate = NSPredicate(format: "isRead == 0")
        let count = managedObjectContext.countForFetchRequest(request, error: nil)
        notification.applicationIconBadgeNumber = count
        
        if notification.respondsToSelector("regionTriggersOnce") {
            notification.regionTriggersOnce = true
        }
        
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func clearNotifications () {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    func approveMemeberWithUserInfo(userInfo: [NSObject: AnyObject]) {
        let message = userInfo["aps"] as [NSObject: AnyObject]
        if let approveMemberDetails = userInfo["approve_member"] as? [NSObject: AnyObject] {
            var dict = [NSObject: AnyObject]()
            dict["message"] = message["alert"]
            dict["title"] = NEW_MEMBER
            dict["membershipId"] = approveMemberDetails["membership_id"] as Int
            NSUserDefaults.standardUserDefaults().setValue(dict, forKey: "approveMember")
            NSNotificationCenter.defaultCenter().postNotificationName(kApproveMemberNotificationName, object: self, userInfo: dict)
        }
    }
    
    func fetchNewAudioWithGroupId(groupId: Int) {
        let request = NSFetchRequest(entityName: "Group")
        let predicate = NSPredicate(format: "serverId == %i", groupId)
        request.predicate = predicate
        if let groups = managedObjectContext.executeFetchRequest(request, error: nil) as? [Group] {
            let group = groups[0]
            group.fetchMessages() {
                println("fetched message for group \(group.name)")
            }
        }
    }
    
    func playAlert() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        AudioServicesPlaySystemSound(1007)
    }
}
