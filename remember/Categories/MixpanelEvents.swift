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
let kAddLocationEventTitle = "Added Location"

enum RegionType: String {
    case Geographic = "Geographic"
    case Beacon = "iBeacon"
}

enum RegionEventType: String {
    case Enter = "Enter"
    case Exit = "Exit"
}

protocol MixpanelEvent {
    var title: String { get }
    var properties: [String: NSObject] { get }
    var date: NSDate { get }
}

protocol RegionEvent: MixpanelEvent {
    var regionType: RegionType { get }
    var eventType: RegionEventType { get }
    var scene: CLLocation { get }
}

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
        title += ": \(region.identifier)"
        properties[kRegionType] = regionType.rawValue
        properties[kEventType] = eventType.rawValue
        properties[kIdentifier] = region.identifier
        properties[kRegionCenterLongitude] = region.center.longitude
        properties[kRegionCenterLatitude] = region.center.latitude
        properties[kSceneLongitude] = scene.coordinate.longitude
        properties[kSceneLatitude] = scene.coordinate.latitude
        properties[kSceneDescripton] = scene.description
        properties[kDate] = NSDate()
        let distance = (region.center.distanceFromCoordinate(scene.coordinate) / 1000).format("0.03")
        properties[kDistance] = "\(distance)km"
    }
}

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

struct VisitEvent: MixpanelEvent {
    var title: String
    var properties = [String: NSObject]()
    var visit: CLVisit
    var scene: CLLocation
    let date = NSDate()
    
    init(visit: CLVisit, scene: CLLocation) {
        self.visit = visit
        self.scene = scene
        switch visit.departureDate.compare(NSDate.distantFuture() as NSDate) {
        case .OrderedSame:
            title = kVisitArrivalEventTitle
        default:
            title = kVisitDepartureEventTitle
        }
        properties[kArrivalDate] = visit.arrivalDate
        properties[kDepartureDate] = visit.departureDate
        properties[kVisitLatitude] = visit.coordinate.latitude
        properties[kVisitLongitude] = visit.coordinate.longitude
        properties[kSceneLongitude] = scene.coordinate.longitude
        properties[kSceneLatitude] = scene.coordinate.latitude
        properties[kSceneDescripton] = scene.description
        let distance = (visit.coordinate.distanceFromCoordinate(scene.coordinate) / 1000).format("0.03")
        properties[kDistance] = "\(distance)km"
        properties[kDate] = date
    }
}

struct AddLocationEvent: MixpanelEvent {
    var title = kAddLocationEventTitle
    var properties = [String: NSObject]()
    var location: Location
    let date = NSDate()
    
    init(location: Location) {
        self.location = location
        if location.uuid != "" {
            title += " (iBeacon Region)"
            properties[kUUID] = location.uuid
            properties[kMajor] = location.major
            properties[kMinor] = location.minor
        } else {
            title += " (Geographic Region)"
            properties[kRegionCenterLatitude] = location.latitude
            properties[kRegionCenterLongitude] = location.longitude
        }
        properties[kIdentifier] = location.identifier
    }
}