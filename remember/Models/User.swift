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
    
    class func currentUserId() -> Int? {
        return NSUserDefaults.standardUserDefaults().valueForKey("userId") as? Int
    }
    
    class func isRegistered() -> Bool {
        if currentUserId() != nil {
            return true
        } else {
            return false
        }
    }
    
    func createAccount(callback: (() -> Void)?) {
        let data = UIImagePNGRepresentation(image)
        let dataDetails = (key: "user[profile_picture]", data: data!, type: "image/png", filename: "\(UIDevice.currentDevice().identifierForVendor.UUIDString).png")
        let parameters = [
            "user[device_id]": UIDevice.currentDevice().identifierForVendor.UUIDString,
            "user[device_type]": "iOS",
            "user[nickname]": nickname,
            "user[device_token]": NSUserDefaults.standardUserDefaults().valueForKey("token") as String
        ]
        
        image.saveImageAsPNGWithName("user")
        
        APIManager.postMultipartData(dataDetails, parameters: parameters, url: NSURL(string: kUsersURL)!) { (response, error, jsonObject) -> Void in
            if let id = jsonObject["id"].number {
                NSUserDefaults.standardUserDefaults().setValue(id, forKey: "userId")
                println("saved server user id: \(id)")
                if let cb = callback {
                    cb()
                }
            }
        }
        
        Mixpanel.sharedInstance().track("createUserAccount")
    }
    
    class func downloadProfileImageForUserId(id: Int) {
        let url = NSURL(string: kUsersURL + "/\(id)")!
        let path = kApplicationPath.stringByAppendingPathComponent("user-\(id).png")
        println("path: \(path)")
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            APIManager.sendRequest(toURL: url, method: HTTPMethodType.GET, json: nil, callback: { (response, error, jsonObject) -> Void in
                let imageUrl = NSURL(string: jsonObject["profile_picture_url"].stringValue)!
                println("image url: \(imageUrl)")
                let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
                let session = NSURLSession(configuration: sessionConfig)
                let task = session.downloadTaskWithURL(imageUrl, completionHandler: { (location, response, error) -> Void in
                    if error != nil {
                        println("error: \(error)")
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let data = NSData(contentsOfURL: location) {
                            data.writeToFile(path, atomically: true)
                        }
                    })
                })
                task.resume()
            })
        }
    }
}
