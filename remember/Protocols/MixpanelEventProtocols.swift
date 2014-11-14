//
//  MixpanelEventProtocol.swift
//  remember
//
//  Created by Joseph Cheung on 14/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreLocation

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
