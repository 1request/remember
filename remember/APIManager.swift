//
//  APIManager.swift
//  remember
//
//  Created by Joseph Cheung on 25/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class APIManager: NSObject {

    class func postMultipartData(data: (key: String, data: NSData, type: String, filename: String), parameters: [String: NSObject], url:NSURL) {
        let request = NSMutableURLRequest(URL: url)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        request.HTTPShouldHandleCookies = false
        request.timeoutInterval = 30
        request.HTTPMethod = "POST"
        
        let contentType = "multipart/form-data; boundary=\(kBoundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let value = request.valueForHTTPHeaderField("Content-Type")
        var body = NSMutableData()
        
        let boundary = "--\(kBoundary)\r\n"
        for (key, value) in parameters {
            let contentDisposition = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
            let paramKey = "\(value)\r\n"
            
            body.appendString(boundary)
            body.appendString(contentDisposition)
            body.appendString(paramKey)
        }
        let dataContentDisposition = "Content-Disposition: form-data; name=\"\(data.key)\"; filename=\"\(data.filename)\"\r\n"
        let mimeType = "Content-Type: \(data.type)\r\n\r\n"
        body.appendString(boundary)
        body.appendString(dataContentDisposition)
        body.appendString(mimeType)
        body.appendData(data.data)
        body.appendString("\r\n")
        body.appendString("--\(kBoundary)--\r\n")
        
        request.HTTPBody = body
        let postLength = "\(body.length)"
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        
        postRequest(request) { (success, response, error) -> Void in
            println("response: \(response)")
        }
    }
    
    class func postRequest(request: NSURLRequest, callback: (success: Bool, response: NSURLResponse, error: NSError?) -> Void) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let returnObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            var success = false
            if let parsedObject = returnObject as? [String: String] {
                if (parsedObject["OK"] != nil) {
                    success = true
                } else {
                    println("cannot post to server")
                    println("response: \(parsedObject)")
                    success = false
                }
            }
            session.invalidateAndCancel()
            callback(success: success, response: response, error: error)
        })
        task.resume()
    }
}
