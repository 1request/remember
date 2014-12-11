//
//  Membership.swift
//  remember
//
//  Created by Joseph Cheung on 10/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class Membership: NSObject {
    var id: Int
    var url: NSURL
    init(id: Int) {
        self.id = id
        self.url = NSURL(string: kMembershipsURL + "/\(id)")!
    }
    
    func approve() {
        let json: JSON = ["status": "accepted"]
        APIManager.sendJSON(json, toURL: url, method: HTTPMethodType.PATCH) { (response, error, jsonObject) -> Void in
            println("response: \(response)")
        }
    }
    
    func reject() {
        let json: JSON = nil
        APIManager.sendJSON(json, toURL: url, method: HTTPMethodType.DELETE) { (response, error, jsonObject) -> Void in
            println("response: \(response)")
        }
    }
}
