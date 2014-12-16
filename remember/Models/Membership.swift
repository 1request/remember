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
        APIManager.sendRequest(toURL: url, method: .PATCH, json: json) { (response, error, jsonObject) -> Void in
            println("response: \(response)")
        }
    }
    
    func reject() {
        APIManager.sendRequest(toURL: url, method: .DELETE, json: nil) { (response, error, jsonObject) -> Void in
            println("response: \(response)")
        }
    }
}
