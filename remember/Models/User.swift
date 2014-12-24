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
    
    class func updateProfilePicture(image: UIImage, callback: (() -> Void)?) {
        if let userId = User.currentUserId() {
            image.saveImageAsPNGWithName("user")
            let url = NSURL(string: kUsersURL + "/\(userId)")!
            let data = UIImageJPEGRepresentation(image, 0.6)
            let dataDetails = (key: "user[profile_picture]", data: data!, type: "image/jpeg", filename: "\(UIDevice.currentDevice().identifierForVendor.UUIDString).jpeg")
            APIManager.sendMultipartData(dataDetails, parameters: nil, url: url, type: .PATCH) { (response, error, jsonObject) -> Void in
                if let id = jsonObject["id"].number {
                    NSUserDefaults.standardUserDefaults().setValue(id, forKey: "userId")
                    println("saved server user id: \(id)")
                    if let cb = callback {
                        cb()
                    }
                }
            }
        }
    }
    
    class func updateNickname(name: String) {
        if let userId = User.currentUserId() {
            let paramJson: JSON = ["nickname": name]
            let url = NSURL(string: kUsersURL + "/\(userId)")!
            APIManager.sendRequest(toURL: url, method: .PATCH, json: paramJson, callback: { (response, error, jsonObject) -> Void in
                println("response: \(response)")
            })
        }
    }
    
    func createAccount(callback: (() -> Void)?) {
        let data = UIImageJPEGRepresentation(image, 0.6)
        let dataDetails = (key: "user[profile_picture]", data: data!, type: "image/jpeg", filename: "\(UIDevice.currentDevice().identifierForVendor.UUIDString).jpeg")
        var parameters = [
            "user[device_id]": UIDevice.currentDevice().identifierForVendor.UUIDString,
            "user[device_type]": "iOS",
            "user[nickname]": nickname
        ]
        
        #if !TARGET_IPHONE_SIMULATOR
            parameters["user[device_token]"] = NSUserDefaults.standardUserDefaults().valueForKey("token") as? String
        #endif
        
        image.saveImageAsPNGWithName("user")
        
        NSUserDefaults.standardUserDefaults().setValue(nickname, forKey: "nickname")
        
        APIManager.sendMultipartData(dataDetails, parameters: parameters, url: NSURL(string: kUsersURL)!, type: .POST) { (response, error, jsonObject) -> Void in
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
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            APIManager.sendRequest(toURL: url, method: HTTPMethodType.GET, json: nil, callback: { (response, error, jsonObject) -> Void in
                let imageUrl = NSURL(string: jsonObject["profile_picture_url"].stringValue)!
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
