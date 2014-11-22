//
//  GeographicRegionEvent.swift
//  remember
//
//  Created by Joseph Cheung on 14/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreLocation

struct GeographicRegionEvent: RegionEvent {
    var title: String
    let regionType = RegionType.Geographic
    var eventType: RegionEventType
    var region: CLCircularRegion
    var scene: CLLocation
    var properties = [String: NSObject]()
    let date = NSDate()
    
    init(eventType: RegionEventType, region: CLCircularRegion, scene: CLLocation) {
        self.eventType = eventType
        self.region = region
        self.scene = scene
        switch eventType {
        case .Enter:
            title = kEnteredGeoEventTitle
        case .Exit:
            title = kExitedGeoEventTitle
        }
        properties[kRegionType] = regionType.rawValue
        properties[kEventType] = eventType.rawValue
        properties[kIdentifier] = region.identifier
        properties[kRegionCenterLongitude] = region.center.longitude
        properties[kRegionCenterLatitude] = region.center.latitude
        properties[kSceneLongitude] = scene.coordinate.longitude
        properties[kSceneLatitude] = scene.coordinate.latitude
        properties[kSceneDescripton] = scene.description
        properties[kDate] = date
        properties[kDistance] = region.center.distanceFromCoordinate(scene.coordinate) / 1000
    }
}
