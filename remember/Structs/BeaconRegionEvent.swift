//
//  BeaconRegionEvent.swift
//  remember
//
//  Created by Joseph Cheung on 14/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreLocation

struct BeaconRegionEvent: RegionEvent {
    var title: String
    let regionType = RegionType.Beacon
    var eventType: RegionEventType
    var region: CLBeaconRegion
    var scene: CLLocation
    var properties = [String: NSObject]()
    let date = NSDate()
    
    init(event: RegionEventType, region: CLBeaconRegion, scene: CLLocation) {
        self.eventType = event
        self.region = region
        self.scene = scene
        
        switch eventType {
        case .Enter:
            title = kEnteredBeaconEventTitle
        case .Exit:
            title = kExitedBeaconEventTitle
        }
        
        title += ": \(region.identifier)"
        
        properties[kRegionType] = regionType.rawValue
        properties[kEventType] = eventType.rawValue
        properties[kUUID] = region.proximityUUID.UUIDString
        properties[kMajor] = region.major
        properties[kMinor] = region.minor
        properties[kIdentifier] = region.identifier
        properties[kSceneLongitude] = scene.coordinate.longitude
        properties[kSceneLatitude] = scene.coordinate.latitude
        properties[kSceneDescripton] = scene.description
        properties[kDate] = NSDate()
    }
}
