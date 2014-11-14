//
//  VisitEvent.swift
//  remember
//
//  Created by Joseph Cheung on 14/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreLocation

enum VisitType: String {
    case Arrival = "Arrival"
    case Departure = "Departue"
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
        title = "Visit"
        switch visit.departureDate.compare(NSDate.distantFuture() as NSDate) {
        case .OrderedSame:
            properties[kVisitType] = VisitType.Arrival.rawValue
        default:
            properties[kVisitType] = VisitType.Departure.rawValue
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
