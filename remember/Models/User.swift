//
//  User.swift
//  remember
//
//  Created by Joseph Cheung on 8/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class User: NSObject {
    var nickname: String
    var image: UIImage
    
    init(nickname: String, image: UIImage) {
        self.nickname = nickname
        self.image = image
    }
    
    func createAccount(callback: (() -> Void)?) {
        let data = UIImagePNGRepresentation(image)
        let dataDetails = (key: "user[profile_picture]", data: data!, type: "image/png", filename: "\(UIDevice.currentDevice().identifierForVendor.UUIDString).png")
        let parameters = [
            "user[device_id]": UIDevice.currentDevice().identifierForVendor.UUIDString,
            "user[device_type]": "iOS",
            "user[nickname]": nickname
        ]
        
        image.saveImageAsPNGWithName("user")
        
        APIManager.postMultipartData(dataDetails, parameters: parameters, url: NSURL(string: kUserPOSTURL)!) { (response, error, jsonObject) -> Void in
            if let id = jsonObject["id"].number {
                NSUserDefaults.standardUserDefaults().setValue(id, forKey: "userId")
                let id = NSUserDefaults.standardUserDefaults().valueForKey("userId") as Int
                println("saved server user id: \(id)")
                if let cb = callback {
                    cb()
                }
            }
        }
        
        Mixpanel.sharedInstance().track("createUserAccount")
    }
}
