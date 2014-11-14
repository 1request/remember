//
//  MixpanelEvent.swift
//  remember
//
//  Created by Joseph Cheung on 13/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreLocation

let kRegionType = "Region Type"
let kEventType = "Event Type"
let kRegionCenterLongitude = "Region Center Longitude"
let kRegionCenterLatitude = "Region Center Latitude"
let kSceneLongitude = "Scene Longitude"
let kSceneLatitude = "Scene Latitude"
let kSceneDescripton = "Scene description"
let kDistance = "Distance"
let kDate = "Date"
let kUUID = "iBeacon UUID"
let kMajor = "iBeacon Major"
let kMinor = "iBeacon Minor"
let kIdentifier = "Identifier"
let kArrivalDate = "Arrival Date"
let kDepartureDate = "Departure Date"
let kVisitLatitude = "Visit Latitude"
let kVisitLongitude = "Visit Longitude"
let kEnteredBeaconEventTitle = "Entered iBeacon Region"
let kExitedBeaconEventTitle = "Exited iBeacon Region"
let kEnteredGeoEventTitle = "Entered Geographic Region"
let kExitedGeoEventTitle = "Exited Geographic Region"
let kVisitArrivalEventTitle = "Visit Arrival"
let kVisitDepartureEventTitle = "Visit Departure"

enum RegionType: String {
    case Geographic = "Geographic"
    case Beacon = "iBeacon"
}

enum RegionEventType: String {
    case Enter = "Enter"
    case Exit = "Exit"
}

protocol MixpanelEvent {
    var eventTitle: String { get }
    var eventProperties: [String: NSObject] { get }
}

protocol RegionEvent: MixpanelEvent {
    var regionType: RegionType { get }
    var eventType: RegionEventType { get }
    var scene: CLLocation { get }
}

struct GeographicRegionEvent: RegionEvent {
    var eventTitle: String
    let regionType = RegionType.Geographic
    var eventType: RegionEventType
    var region: CLCircularRegion
    var scene: CLLocation
    var eventProperties = [String: NSObject]()
    
    init(eventType: RegionEventType, region: CLCircularRegion, scene: CLLocation) {
        self.eventType = eventType
        self.region = region
        self.scene = scene
        switch eventType {
        case .Enter:
            eventTitle = kEnteredGeoEventTitle
        case .Exit:
            eventTitle = kExitedGeoEventTitle
        }
        eventTitle += ": \(region.identifier)"
        eventProperties[kRegionType] = regionType.rawValue
        eventProperties[kEventType] = eventType.rawValue
        eventProperties[kIdentifier] = region.identifier
        eventProperties[kRegionCenterLongitude] = region.center.longitude
        eventProperties[kRegionCenterLatitude] = region.center.latitude
        eventProperties[kSceneLongitude] = scene.coordinate.longitude
        eventProperties[kSceneLatitude] = scene.coordinate.latitude
        eventProperties[kSceneDescripton] = scene.description
        eventProperties[kDate] = NSDate()
        let distance = (region.center.distanceFromCoordinate(scene.coordinate) / 1000).format("0.03")
        eventProperties[kDistance] = "\(distance)km"
    }
}

struct BeaconRegionEvent: RegionEvent {
    var eventTitle: String
    let regionType = RegionType.Beacon
    var eventType: RegionEventType
    var region: CLBeaconRegion
    var scene: CLLocation
    var eventProperties = [String: NSObject]()
    
    init(event: RegionEventType, region: CLBeaconRegion, scene: CLLocation) {
        self.eventType = event
        self.region = region
        self.scene = scene
        
        switch eventType {
        case .Enter:
            eventTitle = kEnteredBeaconEventTitle
        case .Exit:
            eventTitle = kExitedBeaconEventTitle
        }
        
        eventTitle += ": \(region.identifier)"
        
        eventProperties[kRegionType] = regionType.rawValue
        eventProperties[kEventType] = eventType.rawValue
        eventProperties[kUUID] = region.proximityUUID.UUIDString
        eventProperties[kMajor] = region.major
        eventProperties[kMinor] = region.minor
        eventProperties[kIdentifier] = region.identifier
        eventProperties[kSceneLongitude] = scene.coordinate.longitude
        eventProperties[kSceneLatitude] = scene.coordinate.latitude
        eventProperties[kSceneDescripton] = scene.description
        eventProperties[kDate] = NSDate()
    }
}

struct VisitEvent: MixpanelEvent {
    var eventTitle: String
    var eventProperties = [String: NSObject]()
    var visit: CLVisit
    var scene: CLLocation
    
    init(visit: CLVisit, scene: CLLocation) {
        self.visit = visit
        self.scene = scene
        switch visit.departureDate.compare(NSDate.distantFuture() as NSDate) {
        case .OrderedSame:
            eventTitle = kVisitArrivalEventTitle
        default:
            eventTitle = kVisitDepartureEventTitle
        }
        eventProperties[kArrivalDate] = visit.arrivalDate
        eventProperties[kDepartureDate] = visit.departureDate
        eventProperties[kVisitLatitude] = visit.coordinate.latitude
        eventProperties[kVisitLongitude] = visit.coordinate.longitude
        eventProperties[kSceneLongitude] = scene.coordinate.longitude
        eventProperties[kSceneLatitude] = scene.coordinate.latitude
        eventProperties[kSceneDescripton] = scene.description
        let distance = (visit.coordinate.distanceFromCoordinate(scene.coordinate) / 1000).format("0.03")
        eventProperties[kDistance] = "\(distance)km"
        eventProperties[kDate] = NSDate()
    }
}
