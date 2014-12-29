//
//  Membership.swift
//  remember
//
//  Created by Joseph Cheung on 10/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class Membership: NSObject {
    var id: Int?
    var url: NSURL?
    var groupId: Int?
    var userId: Int?

    init(id: Int) {
        self.id = id
        self.url = NSURL(string: kMembershipsURL + "/\(id)")!
    }
    
    init(groupId: Int, userId: Int) {
        self.groupId = groupId
        self.userId = userId
    }
    
    func approve(callback: () -> Void) {
        if let goupId = groupId {
            let json: JSON = ["group_id": groupId!, "user_id": userId!]
            APIManager.sendRequest(toURL: NSURL(string: kAcceptURL)!, method: .POST, json: json) { (response, error, jsonObject) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback()
                })
            }
        } else if let id = id {
            let json: JSON = ["status": "accepted"]
            APIManager.sendRequest(toURL: url!, method: .PATCH, json: json) { (response, error, jsonObject) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback()
                })
            }
        }
    }
    
    func reject(callback: () -> Void) {
        if let goupId = groupId {
            let json: JSON = ["group_id": groupId!, "user_id": userId!]
            APIManager.sendRequest(toURL: NSURL(string: kRejectURL)!, method: .POST, json: json) { (response, error, jsonObject) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback()
                })
            }
        } else if let id = id {
            let json: JSON = ["status": "rejected"]
            APIManager.sendRequest(toURL: url!, method: .PATCH, json: json) { (response, error, jsonObject) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback()
                })
            }
        }
    }
    
    func unregister(callback: () -> Void) {
        if let goupId = groupId {
            let json: JSON = ["group_id": groupId!, "user_id": userId!]
            APIManager.sendRequest(toURL: NSURL(string: kUnregisterURL)!, method: .POST, json: json) { (response, error, jsonObject) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback()
                })
            }
        }
    }
    
    func exitGroup(callback: () -> Void) {
        if let goupId = groupId {
            let url = NSURL(string: kGroupsURL + "/\(groupId!)")!
            APIManager.sendRequest(toURL: url, method: .DELETE, json: nil) { (response, error, jsonObject) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback()
                })
            }
        }
    }
}
