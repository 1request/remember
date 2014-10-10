//
//  Extensions.swift
//  remember
//
//  Created by Joseph Cheung on 10/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func appBlueColor() -> UIColor {
        return UIColor(red: 0, green: 145/255, blue: 1, alpha: 1)
    }
    
    class func appGreyColor() -> UIColor {
        return UIColor(red: 197/255, green: 197/255, blue: 197/255, alpha: 1)
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}
