//
//  APIManager.swift
//  remember
//
//  Created by Joseph Cheung on 25/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

enum HTTPMethodType: String {
    case GET = "GET"
    case POST = "POST"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

class APIManager: NSObject {

    class func sendMultipartData(data: (key: String, data: NSData, type: String, filename: String), parameters: [String: NSObject]?, url:NSURL, type: HTTPMethodType, callback: ((response: NSURLResponse, error: NSError?, jsonObject: JSON) -> Void)?) {
        let request = NSMutableURLRequest(URL: url)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        request.HTTPShouldHandleCookies = false
        request.timeoutInterval = 30
        request.HTTPMethod = type.rawValue
        
        let contentType = "multipart/form-data; boundary=\(kBoundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let value = request.valueForHTTPHeaderField("Content-Type")
        var body = NSMutableData()
        
        let boundary = "--\(kBoundary)\r\n"
        
        if let params = parameters {
            for (key, value) in params {
                let contentDisposition = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                let paramKey = "\(value)\r\n"
                
                body.appendString(boundary)
                body.appendString(contentDisposition)
                body.appendString(paramKey)
            }
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
        
        startRequest(request) { (response, error, jsonObject) -> Void in
            if let cb = callback {
                cb(response: response, error: error, jsonObject: jsonObject)
            }
        }
    }
    
    
    
    class func sendRequest(toURL url: NSURL, method: HTTPMethodType, json: JSON?, callback: ((response: NSURLResponse, error: NSError?, jsonObject: JSON) -> Void)?) {
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = method.rawValue
        if let data = json?.rawData() {
            let length = "\(data.length)"
            request.setValue(length, forHTTPHeaderField: "Content-Length")
            request.HTTPBody = data
        }
        startRequest(request) { (response, error, jsonObject) -> Void in
            if let cb = callback {
                cb(response: response, error: error, jsonObject: jsonObject)
            }
        }
    }
    
    private class func startRequest(request: NSURLRequest, callback: (response: NSURLResponse, error: NSError?, jsonObject: JSON) -> Void) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let json = JSON(data: data)
            session.invalidateAndCancel()
            if response != nil {
                callback(response: response, error: error, jsonObject: json)
            }
        })
        task.resume()
    }
}
