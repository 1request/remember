//
//  NotificationController.swift
//  Remember WatchKit Extension
//
//  Created by Joseph Cheung on 19/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import WatchKit
import Foundation


class NotificationController: WKUserNotificationInterfaceController {

    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    
    let apsKeyString = "aps"
    let titleKeyString = "title"
    let categoryKeyString = "category"
    
    override init() {
        super.init()
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        titleLabel.setText(localNotification.alertBody)
        completionHandler(.Custom)
    }
    
    // Pretend local notification
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        
        let apsDict = remoteNotification[apsKeyString] as [String: NSObject]
        
        if let titleString = apsDict[titleKeyString] as? String {
            titleLabel.setText(titleString)
        }
        
        completionHandler(.Custom)
    }
}
