//
//  AddGroupEvent.swift
//  remember
//
//  Created by Joseph Cheung on 14/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation

struct AddGroupEvent: MixpanelEvent {
    var title = kAddGroupEventTitle
    var properties = [String: NSObject]()
    var group: Group
    let date = NSDate()
    
    init(group: Group) {
        self.group = group
        properties["type"] = group.type
        
        if group.location.uuid != "" {
            properties["location_type"] = "beacon"
        } else {
            properties["location_type"] = "gps"
        }
    }
}
