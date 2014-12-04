//
//  AddLocationEvent.swift
//  remember
//
//  Created by Joseph Cheung on 3/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation

struct AddLocationEvent: MixpanelEvent {
    var title = kAddLocationEventTitle
    var properties = [String: NSObject]()
    var location: Location
    let date = NSDate()
    
    init(location: Location) {
        self.location = location
        if location.uuid != "" {
            properties[kUUID] = location.uuid
            properties[kMajor] = location.major
            properties[kMinor] = location.minor
            properties[kRegionType] = RegionType.Beacon.rawValue
        } else {
            properties[kRegionCenterLatitude] = location.latitude
            properties[kRegionCenterLongitude] = location.longitude
            properties[kRegionType] = RegionType.Geographic.rawValue
        }
        properties[kIdentifier] = location.identifier
    }
}
